/*
 * SPDX-FileCopyrightText: 2026 Sprime contributors
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

package com.osfans.trime.ime.edit

import android.content.Context
import android.text.InputType
import android.view.Gravity
import android.view.View
import android.widget.EditText
import android.widget.LinearLayout
import android.widget.ScrollView
import android.widget.TextView
import androidx.appcompat.app.AlertDialog
import com.osfans.trime.data.theme.ColorManager
import com.osfans.trime.ime.core.TrimeInputMethodService
import com.osfans.trime.ime.keyboard.KeyboardWindow
import com.osfans.trime.ime.window.BoardWindow
import com.osfans.trime.ime.window.BoardWindowManager
import org.kodein.di.instance
import splitties.dimensions.dp

/** User managed phrases: tap to type, long press to delete, plus a button to add new ones. */
class PhraseWindow : BoardWindow.NoBarBoardWindow() {
    private val service: TrimeInputMethodService by di.instance()
    private val windowManager: BoardWindowManager by di.instance()

    private val prefs by lazy { context.getSharedPreferences("sprime_phrases", Context.MODE_PRIVATE) }
    private var list: LinearLayout? = null

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
    }

    private fun addRow(text: String) {
        val row = LinearLayout(context).apply {
            orientation = LinearLayout.HORIZONTAL
            setPadding(0, context.dp(4), 0, context.dp(4))
        }
        val content = styled(text).apply {
            layoutParams = LinearLayout.LayoutParams(0, LinearLayout.LayoutParams.WRAP_CONTENT, 1f)
            setOnClickListener {
                service.commitText(text)
                windowManager.attachWindow(KeyboardWindow)
            }
            setOnLongClickListener {
                AlertDialog.Builder(context)
                    .setMessage("删除这条短语？")
                    .setPositiveButton("删除") { _, _ ->
                        save(phrases().filterNot { it == text })
                        refresh()
                    }
                    .setNegativeButton(android.R.string.cancel, null)
                    .show()
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
            container.addView(styled("还没有短语，点右上角「新增」添加"))
        } else {
            items.forEach { addRow(it) }
        }
    }

    private fun addPhrase() {
        val input = EditText(context).apply {
            inputType = InputType.TYPE_CLASS_TEXT
            hint = "输入短语内容"
        }
        AlertDialog.Builder(context)
            .setTitle("新增短语")
            .setView(input)
            .setPositiveButton(android.R.string.ok) { _, _ ->
                val text = input.text?.toString()?.trim().orEmpty()
                if (text.isNotEmpty()) {
                    save(phrases() + text)
                    refresh()
                }
            }
            .setNegativeButton(android.R.string.cancel, null)
            .show()
    }

    override fun onCreateView(): View {
        val root = LinearLayout(context).apply {
            orientation = LinearLayout.VERTICAL
            setPadding(context.dp(6), context.dp(6), context.dp(6), context.dp(6))
            setBackgroundColor(color("keyboard_back_color", 0xFFEEF2F7.toInt()))
        }
        val header = LinearLayout(context).apply {
            orientation = LinearLayout.HORIZONTAL
        }
        val add = styled("新增").apply {
            layoutParams = LinearLayout.LayoutParams(0, LinearLayout.LayoutParams.WRAP_CONTENT, 1f)
            setOnClickListener { addPhrase() }
        }
        val back = styled("返回").apply {
            layoutParams = LinearLayout.LayoutParams(0, LinearLayout.LayoutParams.WRAP_CONTENT, 1f)
            setOnClickListener { windowManager.attachWindow(KeyboardWindow) }
        }
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
