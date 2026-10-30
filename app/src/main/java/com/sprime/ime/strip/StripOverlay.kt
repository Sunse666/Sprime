/*
 * SPDX-FileCopyrightText: 2026 Sprime contributors
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

package com.sprime.ime.strip

import android.accessibilityservice.AccessibilityService
import android.content.Context
import android.graphics.Canvas
import android.graphics.Color
import android.graphics.Paint
import android.graphics.RectF
import android.graphics.Typeface
import android.os.Build
import android.os.Handler
import android.os.Looper
import android.text.TextUtils
import android.view.Gravity
import android.view.MotionEvent
import android.view.View
import android.view.WindowManager
import android.widget.ScrollView
import android.widget.TextView
import com.osfans.trime.ai.AiSettings
import com.osfans.trime.ai.model.AiDelta
import com.osfans.trime.ai.model.ChatMessage
import com.osfans.trime.ai.model.ChatRole
import com.osfans.trime.ai.provider.OpenAiCompatibleProvider
import com.osfans.trime.util.appContext
import com.sprime.ime.access.SprimeAccessibilityService
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.SupervisorJob
import kotlinx.coroutines.launch

/**
 * A slim strip with four buttons and a four light binary counter. Buttons change the
 * selected slot, 清 clears it and 执 runs the prompt bound to that slot.
 */
object StripOverlay {
    private enum class Phase { IDLE, BUSY, READY, FAILED, ODD }

    private const val TOUCH_W_DP = 24
    private const val VISUAL_W_DP = 12
    private const val HEIGHT_DP = 96
    private const val DRAG_SLOP_DP = 6
    private const val LONG_PRESS_MS = 400L
    private const val MAX_ANSWERS = 20

    private var service: AccessibilityService? = null
    private var windowManager: WindowManager? = null
    private var strip: StripView? = null
    private var params: WindowManager.LayoutParams? = null
    private var bubble: View? = null
    private var bubbleParams: WindowManager.LayoutParams? = null
    private var bubbleVisible = false
    private var bubbleMode = 0

    private val scope = CoroutineScope(SupervisorJob() + Dispatchers.Main)
    private val handler = Handler(Looper.getMainLooper())
    private val provider = OpenAiCompatibleProvider()
    private val settings get() = AiSettings()

    private var phase = Phase.IDLE
    private var slot = 0
    private var answer = ""
    private val answers = mutableListOf<Pair<Int, String>>()
    private var answerIndex = 0
    private var imeVisible = false
    private var pending = false
    private var hideBubbleTask: Runnable? = null

    fun attach(accessibilityService: AccessibilityService) {
        release()
        service = accessibilityService
        windowManager = accessibilityService.getSystemService(WindowManager::class.java)
        if (!StripStore.enabled(appContext)) return
        showStrip()
    }

    fun release() {
        hideBubble()
        strip?.let { runCatching { windowManager?.removeView(it) } }
        strip = null
        params = null
        service = null
        windowManager = null
        phase = Phase.IDLE
    }

    /** Called when the settings change so the strip can follow immediately. */
    fun refresh() {
        val current = service ?: return
        release()
        attach(current)
    }

    fun setImeVisible(visible: Boolean) {
        if (imeVisible == visible) return
        imeVisible = visible
        strip?.visibility = if (visible) View.GONE else View.VISIBLE
        if (visible) hideBubble()
    }

    private fun dp(value: Int): Int = (value * appContext.resources.displayMetrics.density).toInt()

    private fun showStrip() {
        val manager = windowManager ?: return
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.O) return
        val view = StripView(appContext)
        val right = StripStore.onRight(appContext)
        val lp =
            WindowManager.LayoutParams(
                dp(TOUCH_W_DP),
                dp(HEIGHT_DP),
                WindowManager.LayoutParams.TYPE_ACCESSIBILITY_OVERLAY,
                WindowManager.LayoutParams.FLAG_NOT_FOCUSABLE or
                    WindowManager.LayoutParams.FLAG_LAYOUT_NO_LIMITS or
                    (if (StripStore.secure(appContext)) WindowManager.LayoutParams.FLAG_SECURE else 0),
                android.graphics.PixelFormat.TRANSLUCENT,
            ).apply {
                gravity = Gravity.TOP or if (right) Gravity.END else Gravity.START
                x = 0
                y = StripStore.y(appContext)
            }
        runCatching { manager.addView(view, lp) }.onSuccess {
            strip = view
            params = lp
            view.visibility = if (imeVisible) View.GONE else View.VISIBLE
        }
    }

    // ---- behaviour ----

    private fun onPlus() {
        slot = if (slot >= 15) 0 else slot + 1
        phase = Phase.IDLE
        strip?.invalidate()
    }

    private fun onMinus() {
        slot = if (slot <= 0) 15 else slot - 1
        phase = Phase.IDLE
        strip?.invalidate()
    }

    private fun onClear() {
        slot = 0
        answers.clear()
        answer = ""
        answerIndex = 0
        phase = Phase.IDLE
        hideBubble()
        strip?.invalidate()
    }

    private fun onExecute() {
        if (pending) return
        val chosen = slot
        if (chosen == 0) {
            phase = Phase.ODD
            strip?.invalidate()
            haptic(false)
            return
        }
        val state = StripStore.state(appContext)
        val rule = state.ruleFor(chosen)
        slot = 0
        strip?.invalidate()
        if (rule == null) {
            phase = Phase.ODD
            strip?.invalidate()
            haptic(false)
            return
        }
        pending = true
        phase = Phase.BUSY
        strip?.invalidate()
        scope.launch {
            val result = runCatching { runRule(rule) }.getOrNull()
            pending = false
            if (result == null) {
                phase = Phase.FAILED
                haptic(false)
            } else {
                phase = Phase.READY
                haptic(true)
                answers.clear()
                answers.addAll(result)
                answerIndex = 0
                answer = answers.firstOrNull()?.let { formatEntry(it) } ?: ""
                refreshBubble()
            }
            strip?.invalidate()
        }
    }

    private fun formatEntry(entry: Pair<Int, String>): String = "" + entry.first + entry.second

    private suspend fun runRule(rule: StripRule): List<Pair<Int, String>>? {
        val screenText =
            if (rule.readScreen) {
                com.sprime.ime.access.SprimeActions.describeScreen(rule.maxChars)
                    ?: SprimeAccessibilityService.readScreen(rule.maxChars)
            } else {
                null
            }
        val image =
            if (rule.useScreenshot && screenText.isNullOrBlank()) {
                SprimeAccessibilityService.captureScreenshot(imeBottom())
            } else {
                null
            }
        if (screenText.isNullOrBlank() && image == null && rule.readScreen) return null

        val system = ChatMessage(ChatRole.SYSTEM, rule.prompt)
        val content =
            buildString {
                if (!screenText.isNullOrBlank()) {
                    append("以下是屏幕上的文字：\n")
                    append(screenText.take(rule.maxChars))
                } else {
                    append("请根据截图回答。")
                }
            }
        val text = StringBuilder()
        provider.chat(settings.requestConfig(), listOf(system, ChatMessage(ChatRole.USER, content, image = image)))
            .collect { delta ->
                if (delta is AiDelta.Text) text.append(delta.value)
            }
        val raw = text.toString().trim()
        if (raw.isEmpty()) return null
        return when (rule.resultMode) {
            ResultMode.ANSWER_TABLE -> parseAnswers(raw) ?: listOf(0 to raw.take(3))
            ResultMode.PLAIN_TEXT -> listOf(0 to raw)
            ResultMode.INSERT_TEXT -> listOf(0 to raw.take(MAX_ANSWERS))
        }
    }

    private fun parseAnswers(raw: String): List<Pair<Int, String>>? {
        val found = LinkedHashMap<Int, String>()
        Regex("(?m)^\\s*(\\d{1,2})\\s*[.、:：]?\\s*([A-Ea-e√×]|X|x)\\s*$").findAll(raw).forEach { m ->
            if (found.size < MAX_ANSWERS) {
                m.groupValues[1].toIntOrNull()?.let { found[it] = m.groupValues[2].uppercase() }
            }
        }
        if (found.isEmpty()) {
            Regex("([0-9]{1,2})\\s*([A-Ea-e√×])").findAll(raw).forEach { m ->
                if (found.size < MAX_ANSWERS) {
                    m.groupValues[1].toIntOrNull()?.let { found.putIfAbsent(it, m.groupValues[2].uppercase()) }
                }
            }
        }
        if (found.isEmpty()) return null
        return found.entries.sortedBy { it.key }.map { it.key to it.value }.take(MAX_ANSWERS)
    }

    private fun imeBottom(): Int = appContext.resources.displayMetrics.heightPixels

    private fun haptic(success: Boolean) {
        strip?.performHapticFeedback(
            if (success) android.view.HapticFeedbackConstants.CONFIRM else android.view.HapticFeedbackConstants.REJECT,
        )
    }

    // ---- bubble ----

    private fun toggleBubble() {
        bubbleMode = when {
            !bubbleVisible -> 1
            bubbleMode == 1 -> 2
            else -> 0
        }
        if (bubbleMode == 0) hideBubble() else showBubble()
    }

    private fun refreshBubble() {
        if (bubbleVisible) showBubble()
    }

    private fun showBubble() {
        val manager = windowManager ?: return
        hideBubbleView()
        val tableMode = bubbleMode >= 2 && answers.size > 1
        val content =
            if (tableMode) {
                answers.joinToString("\n") { formatEntry(it) }
            } else {
                (answer.ifBlank { "X" }).take(12)
            }
        val text =
            TextView(appContext).apply {
                setText(content)
                textSize = if (tableMode) 13f else 20f
                typeface = Typeface.DEFAULT_BOLD
                setTextColor(Color.parseColor("#1F2937"))
                gravity = if (tableMode) Gravity.START else Gravity.CENTER
                setPadding(dp(8), dp(3), dp(8), dp(3))
                background = android.graphics.drawable.GradientDrawable().apply {
                    cornerRadius = dp(8).toFloat()
                    setColor(Color.parseColor("#F8FAFC"))
                }
            }
        val contentView: View =
            if (tableMode) {
                ScrollView(appContext).apply { addView(text) }
            } else {
                text
            }
        val right = StripStore.onRight(appContext)
        val lp =
            WindowManager.LayoutParams(
                WindowManager.LayoutParams.WRAP_CONTENT,
                WindowManager.LayoutParams.WRAP_CONTENT,
                WindowManager.LayoutParams.TYPE_ACCESSIBILITY_OVERLAY,
                WindowManager.LayoutParams.FLAG_NOT_FOCUSABLE or
                    WindowManager.LayoutParams.FLAG_NOT_TOUCHABLE or
                    WindowManager.LayoutParams.FLAG_LAYOUT_NO_LIMITS or
                    (if (StripStore.secure(appContext)) WindowManager.LayoutParams.FLAG_SECURE else 0),
                android.graphics.PixelFormat.TRANSLUCENT,
            ).apply {
                gravity = Gravity.TOP or if (right) Gravity.END else Gravity.START
                x = dp(VISUAL_W_DP + 6)
                y = (params?.y ?: 0) + dp(HEIGHT_DP) / 2
            }
        runCatching { manager.addView(contentView, lp) }.onSuccess {
            bubble = contentView
            bubbleParams = lp
            bubbleVisible = true
            scheduleHide()
        }
    }

    private fun scheduleHide() {
        hideBubbleTask?.let(handler::removeCallbacks)
        val delay = StripStore.bubbleMs(appContext).toLong()
        if (delay <= 0L) return
        val task = Runnable { hideBubble() }
        hideBubbleTask = task
        handler.postDelayed(task, delay)
    }

    private fun hideBubble() {
        bubbleMode = 0
        hideBubbleView()
    }

    private fun hideBubbleView() {
        hideBubbleTask?.let(handler::removeCallbacks)
        hideBubbleTask = null
        bubble?.let { runCatching { windowManager?.removeView(it) } }
        bubble = null
        bubbleVisible = false
    }

    private fun moveTo(y: Int) {
        val lp = params ?: return
        val maxY = appContext.resources.displayMetrics.heightPixels - dp(HEIGHT_DP)
        lp.y = y.coerceIn(0, maxY)
        strip?.let { runCatching { windowManager?.updateViewLayout(it, lp) } }
        StripStore.setY(appContext, lp.y)
        if (bubbleVisible) {
            bubbleParams?.let { bp ->
                bp.y = lp.y + dp(HEIGHT_DP) / 2
                bubble?.let { runCatching { windowManager?.updateViewLayout(it, bp) } }
            }
        }
    }

    private fun lampColor(on: Boolean): Int =
        if (on) 0xFFF59E0B.toInt() else 0x33F59E0B.toInt()

    private fun lightColor(): Int =
        when (phase) {
            Phase.IDLE -> 0xFFF59E0B.toInt()
            Phase.BUSY -> 0xFF3B82F6.toInt()
            Phase.READY -> 0xFF22C55E.toInt()
            Phase.FAILED -> 0xFFEF4444.toInt()
            Phase.ODD -> 0xFFA855F7.toInt()
        }

    // ---- drawing ----

    private class StripView(
        context: Context,
    ) : View(context) {
        private val paint = Paint(Paint.ANTI_ALIAS_FLAG)
        private var downY = 0f
        private var originY = 0
        private var dragging = false
        private var longPressFired = false
        private val longPress = Runnable {
            if (!dragging) {
                longPressFired = true
                StripOverlay.toggleBubble()
            }
        }

        init {
            isClickable = true
        }

        override fun onDraw(canvas: Canvas) {
            val w = StripOverlay.dp(StripOverlay.VISUAL_W_DP).toFloat()
            val h = height.toFloat()
            val slotValue = StripOverlay.slotValue()
            val centerX = w / 2f
            for (index in 0 until 4) {
                // index 0 is the top lamp, 3 is the bottom one
                val cy = h * (index + 0.5f) / 4f
                val bit = 3 - index
                val on = (slotValue shr bit) and 1 == 1
                paint.style = Paint.Style.FILL
                paint.color = if (index == 3) StripOverlay.lightColor() else StripOverlay.lampColor(on)
                canvas.drawCircle(centerX, cy, StripOverlay.dp(3).toFloat(), paint)
            }
        }

        override fun onTouchEvent(event: MotionEvent): Boolean {
            when (event.actionMasked) {
                MotionEvent.ACTION_DOWN -> {
                    downY = event.rawY
                    originY = StripOverlay.currentY()
                    dragging = false
                    longPressFired = false
                    if (segment(event.y) == 3) {
                        StripOverlay.postDelayed(longPress, LONG_PRESS_MS)
                    }
                    return true
                }

                MotionEvent.ACTION_MOVE -> {
                    val delta = event.rawY - downY
                    if (!dragging && kotlin.math.abs(delta) > StripOverlay.dp(DRAG_SLOP_DP)) {
                        dragging = true
                        StripOverlay.cancelLongPress(longPress)
                    }
                    if (dragging) StripOverlay.moveTo(originY + delta.toInt())
                    return true
                }

                MotionEvent.ACTION_UP -> {
                    StripOverlay.cancelLongPress(longPress)
                    if (!dragging && !longPressFired) {
                        when (segment(event.y)) {
                            0 -> StripOverlay.onPlus()
                            1 -> StripOverlay.onMinus()
                            2 -> StripOverlay.onClear()
                            3 -> StripOverlay.onExecute()
                        }
                    }
                    return true
                }

                MotionEvent.ACTION_CANCEL -> {
                    StripOverlay.cancelLongPress(longPress)
                    return true
                }
            }
            return super.onTouchEvent(event)
        }

        private fun segment(y: Float): Int {
            val buttonH = height / 4f
            return (y / buttonH).toInt().coerceIn(0, 3)
        }
    }

    // ---- helpers used by StripView ----

    private fun slotValue(): Int = slot

    private fun currentY(): Int = params?.y ?: 0

    private fun postDelayed(
        runnable: Runnable,
        delay: Long,
    ) = handler.postDelayed(runnable, delay)

    private fun cancelLongPress(runnable: Runnable) = handler.removeCallbacks(runnable)
}
