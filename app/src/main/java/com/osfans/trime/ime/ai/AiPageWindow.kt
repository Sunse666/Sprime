/*
 * SPDX-FileCopyrightText: 2026 Sprime contributors
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

package com.osfans.trime.ime.ai

import android.graphics.Color
import android.view.Gravity
import android.view.View
import android.widget.LinearLayout
import android.widget.TextView
import com.osfans.trime.R
import com.osfans.trime.data.theme.ColorManager
import com.osfans.trime.ime.keyboard.KeyboardWindow
import com.osfans.trime.ime.window.BoardWindow
import com.osfans.trime.ime.window.BoardWindowManager
import org.kodein.di.instance

/**
 * Placeholder AI page. It takes over the keyboard area at the same height, so
 * opening it never changes the IME insets.
 */
class AiPageWindow : BoardWindow.NoBarBoardWindow() {
    private val windowManager: BoardWindowManager by di.instance()

    override fun onCreateView(): View {
        val textColor = runCatching { ColorManager.getColor("key_text_color") }.getOrDefault(Color.WHITE)
        val backgroundColor =
            runCatching { ColorManager.getColor("keyboard_back_color") }.getOrDefault(Color.BLACK)
        return LinearLayout(context).apply {
            orientation = LinearLayout.VERTICAL
            gravity = Gravity.CENTER
            setBackgroundColor(backgroundColor)
            addView(
                TextView(context).apply {
                    text = context.getString(R.string.ai_panel_title)
                    textSize = 22f
                    setTextColor(textColor)
                    gravity = Gravity.CENTER
                },
            )
            addView(
                TextView(context).apply {
                    text = context.getString(R.string.ai_panel_hint)
                    textSize = 14f
                    setTextColor(textColor)
                    gravity = Gravity.CENTER
                    setPadding(32, 16, 32, 16)
                },
            )
            addView(
                TextView(context).apply {
                    text = context.getString(R.string.ai_back_to_keyboard)
                    textSize = 15f
                    setTextColor(textColor)
                    gravity = Gravity.CENTER
                    setPadding(24, 12, 24, 12)
                    setOnClickListener { windowManager.attachWindow(KeyboardWindow) }
                },
            )
        }
    }

    override fun onAttached() {}

    override fun onDetached() {}
}
