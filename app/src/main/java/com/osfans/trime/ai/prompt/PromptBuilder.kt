/*
 * SPDX-FileCopyrightText: 2026 Sprime contributors
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

package com.osfans.trime.ai.prompt

import com.osfans.trime.ai.context.EditorContext

object PromptBuilder {
    private const val MAX_CONTENT = 4000
    private const val MAX_PERSONA = 2000

    private val BASE_PROMPT =
        "你是 Sprime，一个嵌在安卓键盘里的助手。用户在别的 App 里打字，可能会让你翻译、改写或回答问题。" +
            "回答要简短。翻译或改写类任务只输出结果，不要解释。" +
            "如果回答里包含应该让用户直接输入的文字，用 <insert> 和 </insert> 把那段文字单独包起来，" +
            "其余说明放在标签外；没有要输入的内容就不要加标签。" +
            "你有一个截屏工具：当用户让你看屏幕，或仅凭文字无法回答时，" +
            "只回复 [screenshot]，不要输出别的内容，之后你会收到截图再作答。" +
            "你不能点击、滑动或操作其他 App；如果被要求这么做，简要说明并改为提供可以插入的文字。"

    fun systemMessage(extra: String): String = buildString {
        append(BASE_PROMPT)
        if (extra.isNotBlank()) {
            append("\n\n")
            append(extra.trim().take(MAX_PERSONA))
        }
    }

    fun build(
        action: AiAction,
        content: String,
    ): String = action.instruction + "\n\n" + content.trim().take(MAX_CONTENT)

    fun buildCustom(
        question: String,
        context: EditorContext,
        screenText: String = "",
    ): String {
        val content =
            listOf(context.selection.orEmpty(), screenText)
                .map { it.trim() }
                .firstOrNull { it.isNotEmpty() }
                .orEmpty()
                .take(MAX_CONTENT)
        return if (content.isEmpty()) {
            question
        } else {
            question + "\n\n---\n" + content
        }
    }
}
