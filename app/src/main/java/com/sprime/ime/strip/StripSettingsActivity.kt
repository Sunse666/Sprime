/*
 * SPDX-FileCopyrightText: 2026 Sprime contributors
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

package com.sprime.ime.strip

import android.app.AlertDialog
import android.os.Bundle
import android.text.InputType
import android.view.Gravity
import android.view.ViewGroup
import android.widget.Button
import android.widget.CheckBox
import android.widget.EditText
import android.widget.LinearLayout
import android.widget.ScrollView
import android.widget.Switch
import android.widget.TextView
import androidx.appcompat.app.AppCompatActivity

/** Standalone settings screen for the side strip, its rules and its slots. */
class StripSettingsActivity : AppCompatActivity() {
    private lateinit var rulesColumn: LinearLayout
    private lateinit var slotsColumn: LinearLayout
    private lateinit var stripSwitch: Switch
    private lateinit var secureSwitch: Switch
    private lateinit var sideValue: TextView
    private lateinit var bubbleValue: TextView

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        title = "侧边条"
        val scroll = ScrollView(this)
        val column = LinearLayout(this).apply {
            orientation = LinearLayout.VERTICAL
            setPadding(dip(20), dip(16), dip(20), dip(24))
        }
        scroll.addView(column)
        setContentView(scroll)

        column.addView(sectionTitle("显示"))
        stripSwitch = Switch(this).apply {
            text = "显示侧边条"
            isChecked = StripStore.enabled(this@StripSettingsActivity)
            setOnCheckedChangeListener { _, value ->
                StripStore.setEnabled(this@StripSettingsActivity, value)
                StripOverlay.refresh()
            }
        }
        column.addView(stripSwitch)

        sideValue = row(column, "位置", if (StripStore.onRight(this)) "右侧" else "左侧") { showSideDialog() }
        bubbleValue = row(column, "气泡停留时长", StripStore.bubbleMs(this).toString() + " ms") { showBubbleDialog() }
        secureSwitch = Switch(this).apply {
            text = "禁止被截图"
            isChecked = StripStore.secure(this@StripSettingsActivity)
            setOnCheckedChangeListener { _, value ->
                StripStore.setSecure(this@StripSettingsActivity, value)
                StripOverlay.refresh()
            }
        }
        column.addView(secureSwitch)

        column.addView(sectionTitle("规则"))
        rulesColumn = LinearLayout(this).apply { orientation = LinearLayout.VERTICAL }
        column.addView(rulesColumn)
        column.addView(
            Button(this).apply {
                text = "新增规则"
                setOnClickListener { editRule(null) }
            },
        )

        column.addView(sectionTitle("指令（1–15）"))
        slotsColumn = LinearLayout(this).apply { orientation = LinearLayout.VERTICAL }
        column.addView(slotsColumn)

        render()
    }

    private fun dip(value: Int): Int = (value * resources.displayMetrics.density).toInt()

    private fun sectionTitle(text: String): TextView =
        TextView(this).apply {
            this.text = text
            textSize = 14f
            setPadding(0, dip(16), 0, dip(6))
            alpha = 0.7f
        }

    private fun row(
        parent: LinearLayout,
        label: String,
        value: String,
        onClick: () -> Unit,
    ): TextView {
        val view =
            TextView(this).apply {
                text = "$label：$value"
                textSize = 16f
                setPadding(0, dip(12), 0, dip(12))
                setOnClickListener { onClick() }
            }
        parent.addView(view)
        return view
    }

    private fun render() {
        val state = StripStore.state(this)
        rulesColumn.removeAllViews()
        state.rules.forEach { rule ->
            val view =
                TextView(this).apply {
                    text = rule.name + "  ·  " + rule.resultMode.name + "  ·  " + rule.maxChars + " 字"
                    textSize = 15f
                    setPadding(0, dip(10), 0, dip(10))
                    setOnClickListener { editRule(rule) }
                    setOnLongClickListener {
                        AlertDialog.Builder(this@StripSettingsActivity)
                            .setMessage("删除规则「" + rule.name + "」？")
                            .setPositiveButton("删除") { _, _ ->
                                val next = state.copy(rules = state.rules.filterNot { it.id == rule.id })
                                StripStore.saveState(this@StripSettingsActivity, next)
                                render()
                            }
                            .setNegativeButton("取消", null)
                            .show()
                        true
                    }
                }
            rulesColumn.addView(view)
        }
        if (state.rules.isEmpty()) {
            rulesColumn.addView(TextView(this).apply { text = "还没有规则" })
        }

        slotsColumn.removeAllViews()
        for (slot in 1..15) {
            val rule = state.ruleFor(slot)
            val view =
                TextView(this).apply {
                    text = slot.toString().padStart(2, '0') + "  ·  " + (rule?.name ?: "（空）")
                    textSize = 15f
                    setPadding(0, dip(8), 0, dip(8))
                    setOnClickListener { pickRule(slot) }
                }
            slotsColumn.addView(view)
        }
    }

    private fun pickRule(slot: Int) {
        val state = StripStore.state(this)
        val names = mutableListOf("（空）")
        names.addAll(state.rules.map { it.name })
        AlertDialog.Builder(this)
            .setTitle("指令 " + slot)
            .setItems(names.toTypedArray()) { _, which ->
                val ruleId = if (which == 0) null else state.rules[which - 1].id
                StripStore.saveState(this, state.withSlot(slot, ruleId))
                render()
            }
            .setNegativeButton("取消", null)
            .show()
    }

    private fun showSideDialog() {
        val options = arrayOf("左侧", "右侧")
        AlertDialog.Builder(this)
            .setTitle("侧边条位置")
            .setItems(options) { _, which ->
                StripStore.setOnRight(this, which == 1)
                sideValue.text = "位置：" + options[which]
                StripOverlay.refresh()
            }
            .setNegativeButton("取消", null)
            .show()
    }

    private fun showBubbleDialog() {
        val input = EditText(this).apply {
            inputType = InputType.TYPE_CLASS_NUMBER
            setText(StripStore.bubbleMs(this@StripSettingsActivity).toString())
        }
        AlertDialog.Builder(this)
            .setTitle("气泡停留时长（毫秒，0 = 常驻）")
            .setView(input)
            .setPositiveButton("保存") { _, _ ->
                val value = input.text.toString().toIntOrNull() ?: 3000
                StripStore.setBubbleMs(this, value)
                bubbleValue.text = "气泡停留时长：" + value + " ms"
            }
            .setNegativeButton("取消", null)
            .show()
    }

    private fun editRule(existing: StripRule?) {
        val column = LinearLayout(this).apply {
            orientation = LinearLayout.VERTICAL
            setPadding(dip(20), dip(8), dip(20), dip(8))
        }
        val name = EditText(this).apply {
            hint = "规则名称"
            setText(existing?.name.orEmpty())
        }
        val prompt = EditText(this).apply {
            hint = "提示词（发给模型的内容）"
            inputType = InputType.TYPE_CLASS_TEXT or InputType.TYPE_TEXT_FLAG_MULTI_LINE
            minLines = 4
            gravity = Gravity.TOP
            setText(existing?.prompt.orEmpty())
        }
        val readScreen = CheckBox(this).apply {
            text = "读取屏幕文字"
            isChecked = existing?.readScreen ?: true
        }
        val useShot = CheckBox(this).apply {
            text = "附带截图（拿不到文字时）"
            isChecked = existing?.useScreenshot ?: false
        }
        val modes = ResultMode.entries.map { it.name }.toTypedArray()
        var mode = existing?.resultMode ?: ResultMode.ANSWER_TABLE
        val modeView =
            TextView(this).apply {
                text = "结果处理：" + mode.name
                setPadding(0, dip(10), 0, dip(10))
                setOnClickListener {
                    AlertDialog.Builder(this@StripSettingsActivity)
                        .setTitle("结果处理")
                        .setItems(modes) { _, which ->
                            mode = ResultMode.entries[which]
                            text = "结果处理：" + mode.name
                        }
                        .show()
                }
            }
        val maxChars = EditText(this).apply {
            hint = "最大字符数"
            inputType = InputType.TYPE_CLASS_NUMBER
            setText((existing?.maxChars ?: 12000).toString())
        }
        column.addView(name)
        column.addView(prompt)
        column.addView(readScreen)
        column.addView(useShot)
        column.addView(modeView)
        column.addView(maxChars)

        AlertDialog.Builder(this)
            .setTitle(if (existing == null) "新增规则" else "编辑规则")
            .setView(column)
            .setPositiveButton("保存") { _, _ ->
                val state = StripStore.state(this)
                val id = existing?.id ?: "rule_" + System.currentTimeMillis()
                val rule =
                    StripRule(
                        id = id,
                        name = name.text.toString().ifBlank { "未命名" },
                        prompt = prompt.text.toString(),
                        readScreen = readScreen.isChecked,
                        useScreenshot = useShot.isChecked,
                        resultMode = mode,
                        maxChars = maxChars.text.toString().toIntOrNull() ?: 12000,
                    )
                val rules = state.rules.toMutableList()
                val index = rules.indexOfFirst { it.id == id }
                if (index >= 0) rules[index] = rule else rules.add(rule)
                StripStore.saveState(this, state.copy(rules = rules))
                render()
            }
            .setNegativeButton("取消", null)
            .show()
    }
}
