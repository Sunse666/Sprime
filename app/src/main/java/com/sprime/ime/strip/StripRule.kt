/*
 * SPDX-FileCopyrightText: 2026 Sprime contributors
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

package com.sprime.ime.strip

import android.content.Context
import kotlinx.serialization.Serializable
import kotlinx.serialization.json.Json

/** What the strip should do with the model answer. */
@Serializable
enum class ResultMode {
    ANSWER_TABLE,
    PLAIN_TEXT,
    INSERT_TEXT,
}

/** One editable prompt bound to a strip slot. */
@Serializable
data class StripRule(
    val id: String,
    val name: String,
    val prompt: String,
    val readScreen: Boolean = true,
    val useScreenshot: Boolean = false,
    val resultMode: ResultMode = ResultMode.ANSWER_TABLE,
    val maxChars: Int = 20000,
    /** How many characters of the answer are kept for PLAIN_TEXT / INSERT_TEXT. */
    val maxOutputChars: Int = 2000,
)

/** Slot table: index 0..14 maps to a rule id, null means empty. */
@Serializable
data class StripState(
    val rules: List<StripRule> = defaultRules(),
    val slots: List<String?> = List(15) { null },
) {
    fun ruleFor(slot: Int): StripRule? {
        val id = slots.getOrNull(slot - 1) ?: return null
        return rules.firstOrNull { it.id == id }
    }

    fun withSlot(
        slot: Int,
        ruleId: String?,
    ): StripState {
        val next = slots.toMutableList()
        if (slot in 1..15) next[slot - 1] = ruleId
        return copy(slots = next)
    }

    companion object {
        fun defaultRules(): List<StripRule> =
            listOf(
                StripRule(
                    id = "answer",
                    name = "答题",
                    prompt =
                        "你在帮用户做试卷上的选择题。请回答屏幕上所有单选题，每题一行，" +
                            "格式「题号+答案」，例如 1A；判断题用 √ 或 ×；没把握写 X；最多 20 题。" +
                            "只输出答案行，不要解释。",
                    resultMode = ResultMode.ANSWER_TABLE,
                ),
            )
    }
}

object StripStore {
    private const val FILE = "sprime_strip"
    private const val KEY_STATE = "state"
    private const val KEY_ENABLED = "enabled"
    private const val KEY_SIDE_RIGHT = "side_right"
    private const val KEY_SECURE = "secure"
    private const val KEY_BUBBLE_MS = "bubble_ms"
    private const val KEY_Y = "y"

    private val json =
        Json {
            ignoreUnknownKeys = true
            encodeDefaults = true
        }

    private fun prefs(context: Context) = context.getSharedPreferences(FILE, Context.MODE_PRIVATE)

    fun state(context: Context): StripState {
        val raw = prefs(context).getString(KEY_STATE, null) ?: return StripState()
        return runCatching { json.decodeFromString<StripState>(raw) }.getOrElse { StripState() }
    }

    fun saveState(
        context: Context,
        state: StripState,
    ) {
        prefs(context).edit().putString(KEY_STATE, json.encodeToString(state)).apply()
    }

    fun enabled(context: Context): Boolean = prefs(context).getBoolean(KEY_ENABLED, true)

    fun setEnabled(
        context: Context,
        value: Boolean,
    ) = prefs(context).edit().putBoolean(KEY_ENABLED, value).apply()

    fun onRight(context: Context): Boolean = prefs(context).getBoolean(KEY_SIDE_RIGHT, false)

    fun setOnRight(
        context: Context,
        value: Boolean,
    ) = prefs(context).edit().putBoolean(KEY_SIDE_RIGHT, value).apply()

    fun secure(context: Context): Boolean = prefs(context).getBoolean(KEY_SECURE, false)

    fun setSecure(
        context: Context,
        value: Boolean,
    ) = prefs(context).edit().putBoolean(KEY_SECURE, value).apply()

    fun bubbleMs(context: Context): Int = prefs(context).getInt(KEY_BUBBLE_MS, 3000)

    fun setBubbleMs(
        context: Context,
        value: Int,
    ) = prefs(context).edit().putInt(KEY_BUBBLE_MS, value).apply()

    fun y(context: Context): Int = prefs(context).getInt(KEY_Y, 500)

    fun setY(
        context: Context,
        value: Int,
    ) = prefs(context).edit().putInt(KEY_Y, value).apply()
}
