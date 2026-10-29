/*
 * SPDX-FileCopyrightText: 2026 Sprime contributors
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

package com.osfans.trime.ime.edit

import android.annotation.SuppressLint
import android.os.SystemClock
import android.view.Gravity
import android.view.KeyEvent
import android.view.View
import android.widget.GridLayout
import android.widget.TextView
import com.osfans.trime.data.theme.ColorManager
import com.osfans.trime.data.theme.Theme
import com.osfans.trime.ime.clipboard.ClipboardWindow
import com.osfans.trime.ime.core.TrimeInputMethodService
import com.osfans.trime.ime.keyboard.KeyboardWindow
import com.osfans.trime.ime.window.BoardWindow
import com.osfans.trime.ime.window.BoardWindowManager
import org.kodein.di.instance
import splitties.dimensions.dp

/** Editing panel shown instead of the keyboard: selection, clipboard and cursor control. */
class EditWindow : BoardWindow.NoBarBoardWindow() {
    private val service: TrimeInputMethodService by di.instance()
    private val windowManager: BoardWindowManager by di.instance()
    private val theme: Theme by di.instance()

    private var selectMode = false
    private var selectButton: TextView? = null

    private val labels = listOf(
        "全选", "上页", "↑", "下页", "短语",
        "剪切", "←", "选择", "→", "剪切板",
        "复制", "行首", "↓", "行尾", "⌫",
        "粘贴", "撤销", "清空", "重做", "返回",
    )

    private fun color(name: String, fallback: Int) = runCatching { ColorManager.getColor(name) }.getOrDefault(fallback)

    private fun roundRect(color: Int, radius: Int) = android.graphics.drawable.GradientDrawable().apply {
        setColor(color)
        cornerRadius = radius.toFloat()
    }

    @SuppressLint("ClickableViewAccessibility")
    private fun button(text: String): TextView = TextView(context).apply {
        setText(text)
        gravity = Gravity.CENTER
        textSize = 16f
        setTextColor(color("key_text_color", 0xFF1F2937.toInt()))
        background = roundRect(color("key_back_color", 0xFFE7EEF7.toInt()), context.dp(10))
        isClickable = true
        setOnClickListener { onAction(text) }
    }

    private fun key(code: Int, meta: Int = 0) {
        val ic = service.currentInputConnection ?: return
        val now = SystemClock.uptimeMillis()
        ic.sendKeyEvent(KeyEvent(now, now, KeyEvent.ACTION_DOWN, code, 0, meta))
        ic.sendKeyEvent(KeyEvent(now, now, KeyEvent.ACTION_UP, code, 0, meta))
    }

    private fun menu(id: Int) {
        service.currentInputConnection?.performContextMenuAction(id)
    }

    private fun arrow(code: Int) {
        key(code, if (selectMode) KeyEvent.META_SHIFT_ON else 0)
    }

    private fun onAction(text: String) {
        when (text) {
            "全选" -> menu(android.R.id.selectAll)
            "剪切" -> menu(android.R.id.cut)
            "复制" -> menu(android.R.id.copy)
            "粘贴" -> menu(android.R.id.paste)
            "上页" -> key(KeyEvent.KEYCODE_PAGE_UP)
            "下页" -> key(KeyEvent.KEYCODE_PAGE_DOWN)
            "↑" -> arrow(KeyEvent.KEYCODE_DPAD_UP)
            "↓" -> arrow(KeyEvent.KEYCODE_DPAD_DOWN)
            "←" -> arrow(KeyEvent.KEYCODE_DPAD_LEFT)
            "→" -> arrow(KeyEvent.KEYCODE_DPAD_RIGHT)
            "行首" -> key(KeyEvent.KEYCODE_MOVE_HOME)
            "行尾" -> key(KeyEvent.KEYCODE_MOVE_END)
            "⌫" -> key(KeyEvent.KEYCODE_DEL)
            "撤销" -> key(KeyEvent.KEYCODE_Z, KeyEvent.META_CTRL_ON)
            "重做" -> key(KeyEvent.KEYCODE_Z, KeyEvent.META_CTRL_ON or KeyEvent.META_SHIFT_ON)
            "删除" -> Unit
            "清空" -> {
                menu(android.R.id.selectAll)
                key(KeyEvent.KEYCODE_DEL)
            }
            "选择" -> {
                selectMode = !selectMode
                selectButton?.setTextColor(if (selectMode) 0xFF1D4ED8.toInt() else color("key_text_color", 0xFF1F2937.toInt()))
            }
            "短语" -> windowManager.attachWindow(PhraseWindow())
            "剪切板" -> windowManager.attachWindow(ClipboardWindow())
            "返回" -> windowManager.attachWindow(KeyboardWindow)
        }
    }

    override fun onCreateView(): View {
        val grid = GridLayout(context).apply {
            columnCount = 5
            rowCount = 4
            setPadding(context.dp(6), context.dp(6), context.dp(6), context.dp(6))
            setBackgroundColor(color("keyboard_back_color", 0xFFEEF2F7.toInt()))
        }
        val gap = context.dp(4)
        labels.forEach { label ->
            val view = button(label)
            if (label == "选择") selectButton = view
            grid.addView(
                view,
                GridLayout.LayoutParams().apply {
                    width = 0
                    height = 0
                    columnSpec = GridLayout.spec(GridLayout.UNDEFINED, 1f)
                    rowSpec = GridLayout.spec(GridLayout.UNDEFINED, 1f)
                    setMargins(gap, gap, gap, gap)
                },
            )
        }
        return grid
    }

    override fun onAttached() {
        selectMode = false
    }

    override fun onDetached() {
        selectMode = false
    }
}
