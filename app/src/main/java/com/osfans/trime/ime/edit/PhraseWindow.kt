/*
 * SPDX-FileCopyrightText: 2026 Sprime contributors
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

package com.osfans.trime.ime.edit

import android.content.Context
import android.graphics.Color
import android.text.InputType
import android.view.Gravity
import android.view.View
import android.widget.EditText
import android.widget.LinearLayout
import android.widget.ScrollView
import android.widget.TextView
import android.widget.Toast
import com.osfans.trime.data.theme.ColorManager
import com.osfans.trime.ime.core.TrimeInputMethodService
import com.osfans.trime.ime.keyboard.KeyboardWindow
import com.osfans.trime.ime.window.BoardWindow
import com.osfans.trime.ime.window.BoardWindowManager
import org.kodein.di.instance
import splitties.dimensions.dp

/** User managed phrases: tap to type, long press to delete, inline field to add new ones. */
class PhraseWindow : BoardWindow.NoBarBoardWindow() {
    private val service: TrimeInputMethodService by di.instance()
    private val windowManager: BoardWindowManager by di.instance()

    private val prefs by lazy { context.getSharedPreferences("sprime_phrases", Context.MODE_PRIVATE) }
    private var list: LinearLayout? = null
    private var input: EditText? = null

    private fun phrases(): MutableList<String> = prefs.getString(KEY, "")!!.split(SEPARATOR).filter { it.isNotBlank() }.toMutableList()

    private fun save(items: List<String>) {
        prefs.edit().putString(KEY, items.joinToString(SEPARATOR)).apply()
    }

    private fun color(name: String, fallback: Int) = runCatching { ColorManager.getColor(name) }.getOrDefault(fallback)

    private fun roundRect(color: Int, radius: Int) = android.graphics.drawable.GradientDrawable().apply {
        setColor(color)
        cornerRadius = radius.toFloat()
    }

    private fun styled(text: String, size: Float = 16f): TextView = TextView(context).apply {
        setText(text)
        gravity = Gravity.CENTER_VERTICAL
        textSize = size
        setPadding(context.dp(12), context.dp(10), context.dp(12), context.dp(10))
        setTextColor(color("key_text_color", 0xFF1F2937.toInt()))
        background = roundRect(color("key_back_color", 0xFFE7EEF7.toInt()), context.dp(10))
        isClickable = true
    }

    private fun toast(text: String) {
        Toast.makeText(context, text, Toast.LENGTH_SHORT).show()
    }

    private fun addRow(text: String) {
        val row = LinearLayout(context).apply {
            orientation = LinearLayout.HORIZONTAL
            setPadding(0, context.dp(3), 0, context.dp(3))
        }
        val content = styled(text).apply {
            layoutParams = LinearLayout.LayoutParams(0, LinearLayout.LayoutParams.WRAP_CONTENT, 1f)
            setOnClickListener {
                service.commitText(text)
                windowManager.attachWindow(KeyboardWindow)
            }
            setOnLongClickListener {
                save(phrases().filterNot { it == text })
                refresh()
                toast("已删除：$text")
                true
            }
        }
        row.addView(content)
        list?.addView(row)
    }

    private fun refresh() {
        val container = list ?: return
        container.removeAllViews()
        val items = phrases()
        if (items.isEmpty()) {
            container.addView(styled("还没有短语，在上方输入后点「新增」").apply { isClickable = false })
        } else {
            items.forEach { addRow(it) }
        }
    }

    private fun addFromInput() {
        val text = input?.text?.toString()?.trim().orEmpty()
        if (text.isEmpty()) {
            toast("先输入内容")
            return
        }
        save(phrases() + text)
        input?.setText("")
        refresh()
    }

    override fun onCreateView(): View {
        val root = LinearLayout(context).apply {
            orientation = LinearLayout.VERTICAL
            setPadding(context.dp(6), context.dp(6), context.dp(6), context.dp(6))
            setBackgroundColor(color("keyboard_back_color", 0xFFEEF2F7.toInt()))
        }

        val header = LinearLayout(context).apply {
            orientation = LinearLayout.HORIZONTAL
            setPadding(0, 0, 0, context.dp(4))
        }
        val field = EditText(context).apply {
            inputType = InputType.TYPE_CLASS_TEXT
            hint = "输入新短语"
            textSize = 16f
            setTextColor(color("key_text_color", 0xFF1F2937.toInt()))
            setHintTextColor(Color.GRAY)
            setBackground(roundRect(color("key_back_color", 0xFFE7EEF7.toInt()), context.dp(10)))
            setPadding(context.dp(10), context.dp(8), context.dp(10), context.dp(8))
            layoutParams = LinearLayout.LayoutParams(0, LinearLayout.LayoutParams.WRAP_CONTENT, 1f)
        }
        input = field

        val add = styled("新增").apply {
            layoutParams = LinearLayout.LayoutParams(context.dp(72), LinearLayout.LayoutParams.WRAP_CONTENT)
            setOnClickListener { addFromInput() }
        }
        val back = styled("返回").apply {
            layoutParams = LinearLayout.LayoutParams(context.dp(72), LinearLayout.LayoutParams.WRAP_CONTENT)
            setOnClickListener { windowManager.attachWindow(KeyboardWindow) }
        }
        header.addView(field)
        header.addView(add)
        header.addView(back)
        root.addView(header)

        val scroll = ScrollView(context)
        val column = LinearLayout(context).apply { orientation = LinearLayout.VERTICAL }
        scroll.addView(column)
        root.addView(scroll, LinearLayout.LayoutParams(LinearLayout.LayoutParams.MATCH_PARENT, 0, 1f))
        list = column
        refresh()
        return root
    }

    override fun onAttached() = Unit

    override fun onDetached() = Unit

    companion object {
        private const val KEY = "items"
        private const val SEPARATOR = "\u0001"
    }
}
