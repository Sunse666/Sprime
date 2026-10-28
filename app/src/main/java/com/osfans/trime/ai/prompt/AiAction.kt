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
        "翻译下面的内容，只输出译文，保持原有格式。",
    ),
    POLISH(
        R.string.ai_action_polish,
        "把下面的内容改得更通顺自然，保持原意，只输出改写后的文字。",
    ),
    SUMMARIZE(
        R.string.ai_action_summarize,
        "用不超过三条短句总结下面的内容。",
    ),
    EXPLAIN(
        R.string.ai_action_explain,
        "用通俗易懂的话解释下面的内容。",
    ),
    REPLY(
        R.string.ai_action_reply,
        "针对下面的对话写三条简短回复，每条不超过 30 个字。",
    ),
    CONTINUE(
        R.string.ai_action_continue,
        "按下面的语气续写，最多 50 个字，不要解释。",
    ),
}
