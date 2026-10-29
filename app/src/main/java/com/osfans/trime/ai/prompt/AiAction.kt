/*
 * SPDX-FileCopyrightText: 2026 Sprime contributors
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

package com.osfans.trime.ai.prompt

import androidx.annotation.StringRes
import com.osfans.trime.R

enum class AiAction(
    @StringRes val labelRes: Int,
    val defaultInstruction: String,
) {
    TRANSLATE(R.string.ai_action_translate, DefaultPrompts.TRANSLATE),
    POLISH(R.string.ai_action_polish, DefaultPrompts.POLISH),
    SUMMARIZE(R.string.ai_action_summarize, DefaultPrompts.SUMMARIZE),
    EXPLAIN(R.string.ai_action_explain, DefaultPrompts.EXPLAIN),
    REPLY(R.string.ai_action_reply, DefaultPrompts.REPLY),
    CONTINUE(R.string.ai_action_continue, DefaultPrompts.CONTINUE),
}
