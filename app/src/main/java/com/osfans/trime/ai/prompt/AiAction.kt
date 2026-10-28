/*
 * SPDX-FileCopyrightText: 2026 Sprime contributors
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

package com.osfans.trime.ai.prompt

import androidx.annotation.StringRes
import com.osfans.trime.R

enum class AiAction(
    @StringRes val labelRes: Int,
    val instruction: String,
) {
    TRANSLATE(
        R.string.ai_action_translate,
        "Translate the text below. Output only the translation and keep the original formatting.",
    ),
    POLISH(
        R.string.ai_action_polish,
        "Rewrite the text below to be clearer and more natural while keeping the original meaning. " +
            "Output only the rewritten text.",
    ),
    SUMMARIZE(
        R.string.ai_action_summarize,
        "Summarize the text below in at most three short bullet points.",
    ),
    EXPLAIN(
        R.string.ai_action_explain,
        "Explain the text below in plain language for a general reader.",
    ),
    REPLY(
        R.string.ai_action_reply,
        "Write three short reply options for the conversation below. Keep each under 30 characters.",
    ),
    CONTINUE(
        R.string.ai_action_continue,
        "Continue the text below in the same tone. Output at most 50 characters, no explanation.",
    ),
}
