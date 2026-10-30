/*
 * SPDX-FileCopyrightText: 2026 Sprime contributors
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

package com.sprime.ime.overlay

import android.accessibilityservice.AccessibilityService
import android.graphics.Canvas
import android.graphics.Color
import android.graphics.Paint
import android.graphics.RectF
import android.graphics.Typeface
import android.os.Build
import android.os.Handler
import android.os.Looper
import android.view.Gravity
import android.view.MotionEvent
import android.view.View
import android.view.WindowManager
import android.widget.TextView
import com.osfans.trime.ai.AiSettings
import com.osfans.trime.ai.model.ChatMessage
import com.osfans.trime.ai.model.ChatRole
import com.osfans.trime.ai.provider.OpenAiCompatibleProvider
import com.osfans.trime.data.prefs.AppPrefs
import com.osfans.trime.util.appContext
import com.sprime.ime.access.SprimeAccessibilityService
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.SupervisorJob
import kotlinx.coroutines.cancel
import kotlinx.coroutines.launch

/**
 * A tiny strip on the left edge that answers single choice questions without opening
 * a keyboard: tap the upper half to ask, long press the lower half to show the answer.
 */
object QuickAnswerOverlay {
    private enum class State { IDLE, BUSY, READY, FAILED, ODD }

    private const val TOUCH_W_DP = 24
    private const val VISUAL_W_DP = 12
    private const val HEIGHT_DP = 48
    const val DRAG_SLOP_DP = 8
    const val LONG_PRESS_MS = 400L
    private const val MAX_ANSWER_CHARS = 3

    private var service: AccessibilityService? = null
    private var windowManager: WindowManager? = null
    private var strip: StripView? = null
    private var bubble: View? = null
    private var bubbleParams: WindowManager.LayoutParams? = null
    private var params: WindowManager.LayoutParams? = null

    private val scope = CoroutineScope(SupervisorJob() + Dispatchers.Main)
    private val handler = Handler(Looper.getMainLooper())
    private val provider = OpenAiCompatibleProvider()
    private val settings get() = AiSettings()

    private var state = State.IDLE
    private enum class Source { NONE, TEXT, IMAGE }

    private var answer = ""
    private val answers = mutableListOf<Pair<Int, String>>()
    private var answerIndex = 0
    private var source = Source.NONE
    private var bubbleMode = 0

    private var bubbleVisible = false
    private var questionIndex = 1
    private var imeVisible = false
    private var pendingRequest = false
    private var hideBubbleTask: Runnable? = null

    private val prefs get() = AppPrefs.defaultInstance().ai

    /** Turning the switch off must remove the strip immediately. */
    private val stripToggleListener =
        com.osfans.trime.data.prefs.PreferenceDelegate.OnChangeListener<Boolean> { _, enabled ->
            if (enabled) {
                if (strip == null) showStrip()
            } else {
                hideStrip()
            }
        }

    fun attach(accessibilityService: AccessibilityService) {
        release()
        service = accessibilityService
        windowManager = accessibilityService.getSystemService(WindowManager::class.java)
        prefs.quickStripEnabled.registerOnChangeListener(stripToggleListener)
        if (!prefs.quickStripEnabled.getValue()) return
        showStrip()
    }

    /** Removes the strip but keeps listening so the switch can bring it back. */
    fun hideStrip() {
        hideBubble()
        strip?.let { runCatching { windowManager?.removeView(it) } }
        strip = null
        params = null
        state = State.IDLE
    }

    /** Called when the accessibility service goes away. */
    fun release() {
        hideStrip()
        runCatching { prefs.quickStripEnabled.unregisterOnChangeListener(stripToggleListener) }
        service = null
        windowManager = null
    }

    fun detach() = hideStrip()

    fun setImeVisible(visible: Boolean) {
        if (imeVisible == visible) return
        imeVisible = visible
        val view = strip ?: return
        view.visibility = if (visible) View.GONE else View.VISIBLE
        if (visible) hideBubble()
    }

    private fun dp(value: Int): Int = (value * appContext.resources.displayMetrics.density).toInt()

    private fun showStrip() {
        val manager = windowManager ?: return
        val view = StripView(appContext)
        val lp =
            WindowManager.LayoutParams(
                dp(TOUCH_W_DP),
                dp(HEIGHT_DP),
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                    WindowManager.LayoutParams.TYPE_ACCESSIBILITY_OVERLAY
                } else {
                    return
                },
                WindowManager.LayoutParams.FLAG_NOT_FOCUSABLE or
                    WindowManager.LayoutParams.FLAG_LAYOUT_NO_LIMITS or
                    (if (prefs.quickStripSecure.getValue()) WindowManager.LayoutParams.FLAG_SECURE else 0),
                android.graphics.PixelFormat.TRANSLUCENT,
            ).apply {
                gravity = Gravity.TOP or Gravity.START
                x = 0
                y = prefs.quickStripY.getValue()
            }
        runCatching { manager.addView(view, lp) }.onSuccess {
            strip = view
            params = lp
            view.visibility = if (imeVisible) View.GONE else View.VISIBLE
        }
    }

    private fun colorFor(state: State): Int =
        when (state) {
            State.IDLE -> 0x99FFFFFF.toInt()
            State.BUSY -> 0xFF3B82F6.toInt()
            State.READY -> 0xFF22C55E.toInt()
            State.FAILED -> 0xFFEF4444.toInt()
            State.ODD -> 0xFFA855F7.toInt()
        }

    private fun setState(newState: State) {
        state = newState
        strip?.invalidate()
    }


    // ---- helpers used by StripView ----
    private fun stateColor(): Int = colorFor(state)

    /** White means the text came from accessibility, cyan means it came from a screenshot. */
    private fun sourceColor(): Int =
        when (source) {
            Source.TEXT -> 0xEEFFFFFF.toInt()
            Source.IMAGE -> 0xFF06B6D4.toInt()
            Source.NONE -> 0x44FFFFFF.toInt()
        }

    private fun currentY(): Int = params?.y ?: 0

    private fun postDelayed(
        runnable: Runnable,
        delay: Long,
    ) = handler.postDelayed(runnable, delay)

    private fun cancelLongPress(runnable: Runnable) = handler.removeCallbacks(runnable)

    private fun requestAnswer() {
        if (pendingRequest) return
        if (answers.isNotEmpty()) {
            // Answers were fetched in one batch; later taps just walk the list.
            if (answerIndex < answers.lastIndex) {
                answerIndex++
                answer = formatEntry(answers[answerIndex])
                setState(State.READY)
                haptic(true)
                refreshBubble()
            } else {
                setState(State.ODD)
                haptic(false)
            }
            return
        }
        pendingRequest = true
        setState(State.BUSY)
        scope.launch {
            val result = runCatching { fetchAnswers() }.getOrNull()
            pendingRequest = false
            if (result.isNullOrEmpty()) {
                answer = "X"
                setState(State.FAILED)
                haptic(false)
            } else {
                answers.clear()
                answers.addAll(result)
                answerIndex = 0
                answer = formatEntry(answers[0])
                setState(State.READY)
                haptic(true)
                refreshBubble()
            }
        }
    }

    private fun formatEntry(entry: Pair<Int, String>): String = "" + entry.first + entry.second

    /** Asks for every answer of the visible passage in one request. */
    private suspend fun fetchAnswers(): List<Pair<Int, String>>? {
        val screen =
            com.sprime.ime.access.SprimeActions.describeScreen(12000) ?: SprimeAccessibilityService.readScreen(12000)
        val image =
            if (screen.isNullOrBlank()) {
                SprimeAccessibilityService.captureScreenshot(imeBottom())
            } else {
                null
            }
        if (screen.isNullOrBlank() && image == null) return null
        source = if (screen.isNullOrBlank()) Source.IMAGE else Source.TEXT
        strip?.invalidate()

        val cfg = settings.requestConfig()
        val system =
            ChatMessage(
                ChatRole.SYSTEM,
                "你在帮用户做试卷上的选择题。请回答屏幕上所有单选题，每题一行，格式是「题号+答案」，例如 1A；" +
                    "判断题用 √ 或 ×；没有把握的题写 X。只输出答案行，不要解释，不要序号以外的文字，最多 20 题。",
            )
        val content = buildString {
            append("以下是屏幕上的全部文字，可能是一篇文章配多道题。请为每道题给出答案。\n")
            if (!screen.isNullOrBlank()) append(screen.take(12000))
        }
        val user = ChatMessage(ChatRole.USER, content, image = image)
        val text = StringBuilder()
        provider.chat(cfg, listOf(system, user)).collect { delta ->
            if (delta is com.osfans.trime.ai.model.AiDelta.Text) text.append(delta.value)
        }
        return parseAnswers(text.toString())
    }

    private fun imeBottom(): Int = appContext.resources.displayMetrics.heightPixels

    private fun parseAnswers(raw: String): List<Pair<Int, String>>? {
        val found = LinkedHashMap<Int, String>()
        Regex("(?m)^\\s*(\\d{1,2})\\s*[.、:：]?\\s*([A-Ea-e√×]|X|x)\\s*$").findAll(raw).forEach { match ->
            if (found.size >= 20) return@forEach
            val number = match.groupValues[1].toIntOrNull() ?: return@forEach
            found[number] = match.groupValues[2].uppercase()
        }
        if (found.isEmpty()) {
            // Fall back to a loose scan for "3B" tokens.
            Regex("([0-9]{1,2})\\s*([A-Ea-e√×])").findAll(raw).forEach { match ->
                if (found.size >= 20) return@forEach
                val number = match.groupValues[1].toIntOrNull() ?: return@forEach
                found.putIfAbsent(number, match.groupValues[2].uppercase())
            }
        }
        if (found.isEmpty()) return null
        return found.entries.sortedBy { it.key }.map { it.key to it.value }.take(20)
    }

    private fun haptic(success: Boolean) {
        val view = strip ?: return
        view.performHapticFeedback(
            if (success) {
                android.view.HapticFeedbackConstants.CONFIRM
            } else {
                android.view.HapticFeedbackConstants.REJECT
            },
        )
    }

    /** Long press cycles: closed -> single answer -> full table -> closed. */
    private fun toggleBubble() {
        bubbleMode = when {
            !bubbleVisible -> 1
            bubbleMode == 1 -> 2
            else -> 0
        }
        if (bubbleMode == 0) {
            hideBubble()
        } else {
            showBubble()
        }
    }

    private fun refreshBubble() {
        if (!bubbleVisible) return
        showBubble()
    }

    private fun showBubble() {
        val manager = windowManager ?: return
        hideBubbleViewOnly()
        val content =
            if (bubbleMode >= 2 && answers.isNotEmpty()) {
                answers.joinToString("\n") { formatEntry(it) }
            } else {
                (if (answer.isBlank()) "X" else answer).take(MAX_ANSWER_CHARS)
            }
        val view: View =
            TextView(appContext).apply {
                setText(content)
                textSize = if (bubbleMode >= 2) 14f else 20f
                typeface = Typeface.DEFAULT_BOLD
                setTextColor(Color.parseColor("#1F2937"))
                gravity = if (bubbleMode >= 2) Gravity.START else Gravity.CENTER
                setPadding(dp(8), dp(3), dp(8), dp(3))
                background = android.graphics.drawable.GradientDrawable().apply {
                    cornerRadius = dp(8).toFloat()
                    setColor(Color.parseColor("#F8FAFC"))
                }
            }
        val y = (params?.y ?: 0) + dp(HEIGHT_DP) / 2
        val lp =
            WindowManager.LayoutParams(
                WindowManager.LayoutParams.WRAP_CONTENT,
                WindowManager.LayoutParams.WRAP_CONTENT,
                WindowManager.LayoutParams.TYPE_ACCESSIBILITY_OVERLAY,
                WindowManager.LayoutParams.FLAG_NOT_FOCUSABLE or
                    WindowManager.LayoutParams.FLAG_NOT_TOUCHABLE or
                    WindowManager.LayoutParams.FLAG_LAYOUT_NO_LIMITS or
                    (if (prefs.quickStripSecure.getValue()) WindowManager.LayoutParams.FLAG_SECURE else 0),
                android.graphics.PixelFormat.TRANSLUCENT,
            ).apply {
                gravity = Gravity.TOP or Gravity.START
                x = dp(VISUAL_W_DP) + dp(4)
                this.y = y
            }
        runCatching { manager.addView(view, lp) }.onSuccess {
            bubble = view
            bubbleParams = lp
            bubbleVisible = true
            scheduleBubbleHide()
        }
    }

    private fun scheduleBubbleHide() {
        hideBubbleTask?.let(handler::removeCallbacks)
        val delay = prefs.quickBubbleMs.getValue().toLong()
        if (delay <= 0L) return
        val task = Runnable { hideBubble() }
        hideBubbleTask = task
        handler.postDelayed(task, delay)
    }

    private fun hideBubble() {
        bubbleMode = 0
        hideBubbleViewOnly()
    }

    private fun hideBubbleViewOnly() {
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
        prefs.quickStripY.setValue(lp.y)
        if (bubbleVisible) {
            bubbleParams?.let { bp ->
                bp.y = lp.y + dp(HEIGHT_DP) / 2
                bubble?.let { runCatching { windowManager?.updateViewLayout(it, bp) } }
            }
        }
    }

    private class StripView(
        context: android.content.Context,
    ) : View(context) {
        private val paint = Paint(Paint.ANTI_ALIAS_FLAG)
        private var downY = 0f
        private var originY = 0
        private var dragging = false
        private var longPressFired = false
        private val longPressRunnable = Runnable {
            if (!dragging && !longPressFired) {
                longPressFired = true
                QuickAnswerOverlay.toggleBubble()
            }
        }

        init {
            isClickable = true
            setBackgroundColor(Color.TRANSPARENT)
        }

        override fun onAttachedToWindow() {
            super.onAttachedToWindow()
        }

        override fun onSizeChanged(
            w: Int,
            h: Int,
            oldw: Int,
            oldh: Int,
        ) {
            super.onSizeChanged(w, h, oldw, oldh)
        }

        override fun onDraw(canvas: Canvas) {
            val w = QuickAnswerOverlay.dp(QuickAnswerOverlay.VISUAL_W_DP).toFloat()
            val h = height.toFloat()
            val radius = QuickAnswerOverlay.dp(6).toFloat()
            paint.style = Paint.Style.FILL
            paint.color = 0xCC1F2937.toInt()
            canvas.drawRoundRect(RectF(0f, 0f, w, h), radius, radius, paint)

            val cx = w / 2
            paint.color = QuickAnswerOverlay.sourceColor()
            canvas.drawCircle(cx, h * 0.22f, QuickAnswerOverlay.dp(2).toFloat(), paint)

            paint.color = QuickAnswerOverlay.stateColor()
            canvas.drawCircle(cx, h * 0.72f, QuickAnswerOverlay.dp(3).toFloat(), paint)
        }

        override fun onTouchEvent(event: MotionEvent): Boolean {
            when (event.actionMasked) {
                MotionEvent.ACTION_DOWN -> {
                    downY = event.rawY
                    originY = QuickAnswerOverlay.currentY()
                    dragging = false
                    longPressFired = false
                    if (event.y > height / 2f) {
                        QuickAnswerOverlay.postDelayed(longPressRunnable, QuickAnswerOverlay.LONG_PRESS_MS)
                    }
                    return true
                }

                MotionEvent.ACTION_MOVE -> {
                    val delta = event.rawY - downY
                    if (!dragging && kotlin.math.abs(delta) > QuickAnswerOverlay.dp(QuickAnswerOverlay.DRAG_SLOP_DP)) {
                        dragging = true
                        QuickAnswerOverlay.cancelLongPress(longPressRunnable)
                    }
                    if (dragging) QuickAnswerOverlay.moveTo(originY + delta.toInt())
                    return true
                }

                MotionEvent.ACTION_UP -> {
                    QuickAnswerOverlay.cancelLongPress(longPressRunnable)
                    if (!dragging && !longPressFired && event.y <= height / 2f) {
                        QuickAnswerOverlay.requestAnswer()
                    }
                    return true
                }

                MotionEvent.ACTION_CANCEL -> {
                    QuickAnswerOverlay.cancelLongPress(longPressRunnable)
                    return true
                }
            }
            return super.onTouchEvent(event)
        }
    }

}
