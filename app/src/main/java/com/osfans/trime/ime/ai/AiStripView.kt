/*
 * SPDX-FileCopyrightText: 2026 Sprime contributors
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

package com.osfans.trime.ime.ai

import android.content.Context
import android.graphics.Color
import android.text.TextUtils
import android.util.TypedValue
import android.view.Gravity
import android.widget.LinearLayout
import android.widget.TextView
import com.osfans.trime.R
import com.osfans.trime.data.theme.ColorManager
import splitties.dimensions.dp

/**
 * Persistent bar above the keyboard: shows the rime composition and the AI entry.
 * Its height is part of the fixed IME height, so it must never change at runtime.
 */
class AiStripView(
    context: Context,
    onAiClick: () -> Unit,
) : LinearLayout(context) {
    companion object {
        const val HEIGHT_DP = 48
    }

    private val compositionView =
        TextView(context).apply {
            maxLines = 1
            ellipsize = TextUtils.TruncateAt.START
            gravity = Gravity.CENTER_VERTICAL
            setTextSize(TypedValue.COMPLEX_UNIT_SP, 16f)
            text = context.getString(R.string.ai_strip_placeholder)
        }

    private val actionView =
        TextView(context).apply {
            gravity = Gravity.CENTER
            setTextSize(TypedValue.COMPLEX_UNIT_SP, 15f)
            setPadding(dp(14), 0, dp(14), 0)
            setOnClickListener { onAiClick() }
        }

    init {
        orientation = HORIZONTAL
        gravity = Gravity.CENTER_VERTICAL
        isFocusable = false
        setPadding(dp(12), 0, dp(4), 0)
        addView(compositionView, LayoutParams(0, LayoutParams.MATCH_PARENT, 1f))
        addView(actionView, LayoutParams(LayoutParams.WRAP_CONTENT, LayoutParams.MATCH_PARENT))
        setAiPage(false)
        refreshColors()
    }

    fun refreshColors() {
        val textColor = runCatching { ColorManager.getColor("key_text_color") }.getOrDefault(Color.WHITE)
        val accentColor = runCatching { ColorManager.getColor("hilited_key_text_color") }.getOrDefault(textColor)
        compositionView.setTextColor(textColor)
        actionView.setTextColor(accentColor)
    }

    fun setComposition(text: String?) {
        val shown = text?.takeIf { it.isNotEmpty() }
        compositionView.text = shown ?: context.getString(R.string.ai_strip_placeholder)
    }

    fun setAiPage(open: Boolean) {
        actionView.text =
            context.getString(if (open) R.string.ai_back_to_keyboard_short else R.string.ai_assistant)
    }
}
