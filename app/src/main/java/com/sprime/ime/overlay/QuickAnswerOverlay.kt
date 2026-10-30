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

    private const val WIDTH_DP = 36
    private const val HEIGHT_DP = 96
    const val DRAG_SLOP_DP = 8
    const val LONG_PRESS_MS = 400L
    private const val MAX_ANSWER_CHARS = 3

    private var service: AccessibilityService? = null
    private var windowManager: WindowManager? = null
    private var strip: StripView? = null
    private var bubble: TextView? = null
    private var bubbleParams: WindowManager.LayoutParams? = null
    private var params: WindowManager.LayoutParams? = null

    private val scope = CoroutineScope(SupervisorJob() + Dispatchers.Main)
    private val handler = Handler(Looper.getMainLooper())
    private val provider = OpenAiCompatibleProvider()
    private val settings get() = AiSettings()

    private var state = State.IDLE
    private var answer = ""
    private var bubbleVisible = false
    private var questionIndex = 1
    private var imeVisible = false
    private var pendingRequest = false
    private var hideBubbleTask: Runnable? = null

    private val prefs get() = AppPrefs.defaultInstance().ai

    fun attach(accessibilityService: AccessibilityService) {
        if (!prefs.quickStripEnabled.getValue()) return
        if (strip != null) detach()
        service = accessibilityService
        windowManager = accessibilityService.getSystemService(WindowManager::class.java)
        showStrip()
    }

    fun detach() {
        hideBubble()
        strip?.let { runCatching { windowManager?.removeView(it) } }
        strip = null
        params = null
        service = null
        windowManager = null
        state = State.IDLE
    }

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
                dp(WIDTH_DP),
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

    private fun currentY(): Int = params?.y ?: 0

    private fun postDelayed(
        runnable: Runnable,
        delay: Long,
    ) = handler.postDelayed(runnable, delay)

    private fun cancelLongPress(runnable: Runnable) = handler.removeCallbacks(runnable)

    private fun requestAnswer() {
        if (pendingRequest) return
        pendingRequest = true
        setState(State.BUSY)
        val target = questionIndex
        scope.launch {
            val result = runCatching { askModel(target) }.getOrNull()
            pendingRequest = false
            if (result.isNullOrBlank()) {
                answer = "X"
                setState(State.FAILED)
                haptic(false)
            } else {
                answer = result
                setState(State.READY)
                haptic(true)
                questionIndex++
            }
        }
    }

    private suspend fun askModel(index: Int): String? {
        val screen =
            com.sprime.ime.access.SprimeActions.describeScreen() ?: SprimeAccessibilityService.readScreen()
        val image =
            if (screen.isNullOrBlank()) {
                SprimeAccessibilityService.captureScreenshot(imeBottom())
            } else {
                null
            }
        if (screen.isNullOrBlank() && image == null) return null
        val cfg = settings.requestConfig()
        val system =
            ChatMessage(
                ChatRole.SYSTEM,
                "你在帮用户做单选题。只输出「题号+选项字母」，最多三个字符，例如 3B；判断题用 √ 或 ×；" +
                    "无法判断时只输出 X。不要解释，不要标点。",
            )
        val content = buildString {
            append("当前要回答第 ").append(index).append(" 题。\n")
            if (!screen.isNullOrBlank()) append(screen.take(4000))
        }
        val user = ChatMessage(ChatRole.USER, content, image = image)
        val text = StringBuilder()
        provider.chat(cfg, listOf(system, user)).collect { delta ->
            if (delta is com.osfans.trime.ai.model.AiDelta.Text) text.append(delta.value)
        }
        return sanitizeAnswer(text.toString())
    }

    private fun imeBottom(): Int = appContext.resources.displayMetrics.heightPixels

    private fun sanitizeAnswer(raw: String): String? {
        val cleaned = raw.trim()
        if (cleaned.isEmpty()) return null
        val match = Regex("([0-9]{1,2})?\\s*([A-Ea-e√×])").find(cleaned)
        val normalized =
            if (match != null) {
                val number = match.groupValues[1].ifEmpty { questionIndex.toString() }
                number + match.groupValues[2].uppercase()
            } else {
                cleaned.take(MAX_ANSWER_CHARS)
            }
        return normalized.take(MAX_ANSWER_CHARS)
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

    private fun toggleBubble() {
        if (bubbleVisible) {
            hideBubble()
        } else {
            showBubble()
        }
    }

    private fun showBubble() {
        val manager = windowManager ?: return
        val text = if (answer.isBlank()) "X" else answer
        val view =
            TextView(appContext).apply {
                setText(text.take(MAX_ANSWER_CHARS))
                textSize = 20f
                typeface = Typeface.DEFAULT_BOLD
                setTextColor(Color.parseColor("#1F2937"))
                gravity = Gravity.CENTER
                setPadding(dp(6), dp(2), dp(6), dp(2))
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
                x = dp(WIDTH_DP) + dp(4)
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
            val w = width.toFloat()
            val h = height.toFloat()
            val radius = QuickAnswerOverlay.dp(10).toFloat()
            paint.style = Paint.Style.FILL
            paint.color = 0xCC1F2937.toInt()
            canvas.drawRoundRect(RectF(0f, 0f, w, h), radius, radius, paint)

            paint.color = 0x66FFFFFF
            paint.strokeWidth = QuickAnswerOverlay.dp(2).toFloat()
            paint.style = Paint.Style.STROKE
            val inset = QuickAnswerOverlay.dp(4).toFloat()
            canvas.drawRoundRect(
                RectF(inset, inset, w - inset, h - inset),
                radius * 0.8f,
                radius * 0.8f,
                paint,
            )

            paint.style = Paint.Style.FILL
            paint.color = 0xFFFFFFFF.toInt()
            val cx = w / 2
            canvas.drawCircle(cx, h * 0.28f, QuickAnswerOverlay.dp(3).toFloat(), paint)

            paint.color = QuickAnswerOverlay.stateColor()
            canvas.drawCircle(cx, h * 0.72f, QuickAnswerOverlay.dp(5).toFloat(), paint)
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
