/*
 * SPDX-FileCopyrightText: 2026 Sprime contributors
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

package com.osfans.trime.ime.ai

import android.content.Context
import android.graphics.Color
import android.os.Handler
import android.os.Looper
import android.text.TextUtils
import android.util.TypedValue
import android.view.Gravity
import android.view.MotionEvent
import android.view.View
import android.widget.HorizontalScrollView
import android.widget.LinearLayout
import android.widget.TextView
import com.osfans.trime.R
import com.osfans.trime.ai.AiController
import com.osfans.trime.data.theme.ColorManager
import splitties.dimensions.dp

/**
 * Persistent bar above the keyboard: shows the draft (or the rime composition)
 * and the AI action. Its height is part of the fixed IME height.
 */
class AiStripView(
    context: Context,
    private val onAction: () -> Unit,
    private val onActivate: () -> Unit,
    private val onCursorChange: (Int) -> Unit,
) : LinearLayout(context) {
    companion object {
        const val HEIGHT_DP = 48
        private const val CARET_BLINK_MS = 500L
        private const val NEWLINE_MARK = "↵"
    }

    private val scrollView: HorizontalScrollView
    private val textView: TextView
    private val caretView: View
    private val actionView: TextView

    private val handler = Handler(Looper.getMainLooper())
    private val blinkRunnable =
        object : Runnable {
            override fun run() {
                caretView.visibility = if (caretView.visibility == View.VISIBLE) View.INVISIBLE else View.VISIBLE
                handler.postDelayed(this, CARET_BLINK_MS)
            }
        }

    private var composing = false
    private var cursor = 0

    init {
        orientation = HORIZONTAL
        gravity = Gravity.CENTER_VERTICAL
        isFocusable = false
        setPadding(dp(12), 0, dp(4), 0)

        textView =
            TextView(context).apply {
                maxLines = 1
                ellipsize = TextUtils.TruncateAt.END
                gravity = Gravity.CENTER_VERTICAL
                setTextSize(TypedValue.COMPLEX_UNIT_SP, 16f)
                setText(context.getString(R.string.ai_strip_placeholder))
            }

        caretView =
            View(context).apply {
                visibility = View.INVISIBLE
                setBackgroundColor(Color.GRAY)
            }

        val row =
            LinearLayout(context).apply {
                orientation = HORIZONTAL
                gravity = Gravity.CENTER_VERTICAL
                addView(textView, LayoutParams(LayoutParams.WRAP_CONTENT, LayoutParams.MATCH_PARENT))
                addView(caretView, LayoutParams(dp(2), dp(18)))
            }

        scrollView =
            HorizontalScrollView(context).apply {
                isHorizontalScrollBarEnabled = false
                isFocusable = false
                addView(row, LayoutParams(LayoutParams.WRAP_CONTENT, LayoutParams.MATCH_PARENT))
            }

        actionView =
            TextView(context).apply {
                gravity = Gravity.CENTER
                setTextSize(TypedValue.COMPLEX_UNIT_SP, 15f)
                setPadding(dp(14), 0, dp(14), 0)
                setOnClickListener { onAction() }
            }

        addView(scrollView, LayoutParams(0, LayoutParams.MATCH_PARENT, 1f))
        addView(actionView, LayoutParams(LayoutParams.WRAP_CONTENT, LayoutParams.MATCH_PARENT))

        scrollView.setOnTouchListener { _, event ->
            when (event.actionMasked) {
                MotionEvent.ACTION_DOWN -> {
                    if (!composing) onActivate()
                    true
                }

                MotionEvent.ACTION_UP -> {
                    if (composing) moveCursorTo(event.x)
                    true
                }

                else -> true
            }
        }
        setOnClickListener { onActivate() }

        setAiPage(false)
        refreshColors()
    }

    fun refreshColors() {
        val textColor = runCatching { ColorManager.getColor("key_text_color") }.getOrDefault(Color.WHITE)
        val accentColor = runCatching { ColorManager.getColor("hilited_key_text_color") }.getOrDefault(textColor)
        textView.setTextColor(textColor)
        actionView.setTextColor(accentColor)
        caretView.setBackgroundColor(textColor)
    }

    fun setComposition(text: String?) {
        if (composing) return
        textView.text = text?.takeIf { it.isNotEmpty() } ?: context.getString(R.string.ai_strip_placeholder)
        scrollToEnd()
    }

    fun setDraft(state: AiController.Draft) {
        if (!composing) return
        cursor = state.cursor
        textView.text =
            state.text
                .replace("\n", NEWLINE_MARK)
                .ifEmpty { context.getString(R.string.ai_strip_hint) }
        textView.post { updateCaretPosition(state.text.isEmpty()) }
        scrollToCursor()
    }

    fun setComposing(active: Boolean) {
        if (composing == active) return
        composing = active
        if (active) {
            caretView.visibility = View.VISIBLE
            handler.removeCallbacks(blinkRunnable)
            handler.postDelayed(blinkRunnable, CARET_BLINK_MS)
            textView.text = context.getString(R.string.ai_strip_hint)
        } else {
            handler.removeCallbacks(blinkRunnable)
            caretView.visibility = View.INVISIBLE
            textView.text = context.getString(R.string.ai_strip_placeholder)
        }
        cursor = 0
        scrollToEnd()
    }

    fun setAiPage(open: Boolean) {
        actionView.text =
            context.getString(if (open) R.string.ai_back_to_keyboard_short else R.string.ai_assistant)
    }

    private fun moveCursorTo(xInScroll: Float) {
        val layout = textView.layout ?: return
        val x = xInScroll + scrollView.scrollX - textView.left
        val offset = layout.getOffsetForHorizontal(0, x.coerceAtLeast(0f))
        cursor = offset
        onCursorChange(offset)
        updateCaretPosition(textView.text.isEmpty())
    }

    private fun updateCaretPosition(empty: Boolean) {
        val layout = textView.layout ?: return
        val x =
            if (empty || cursor <= 0) {
                0f
            } else {
                layout.getPrimaryHorizontal(cursor.coerceAtMost(layout.text.length))
            }
        caretView.translationX = x - textView.width
    }

    private fun scrollToCursor() {
        scrollView.post {
            val width = scrollView.width
            val layout = textView.layout ?: return@post
            val x =
                if (cursor <= 0) 0f else layout.getPrimaryHorizontal(cursor.coerceAtMost(layout.text.length))
            val target = (x + textView.left - width + dp(32)).toInt().coerceAtLeast(0)
            scrollView.scrollTo(target, 0)
        }
    }

    private fun scrollToEnd() {
        scrollView.post { scrollView.fullScroll(View.FOCUS_RIGHT) }
    }
}
