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
        "You are Sprime, an assistant built into an Android keyboard. " +
            "The user is typing in another app and may ask you to translate, rewrite or answer. " +
            "Keep answers short. When the task is to rewrite or translate text, " +
            "output only the result without explanations. " +
            "When the answer contains text the user should type, wrap exactly that text in " +
            "<insert> and </insert> and keep any comment outside the tags. " +
            "Omit the tags when nothing should be typed. " +
            "You have a screenshot tool: whenever the user asks to look at the screen or the text " +
            "is not enough to answer, reply with exactly [screenshot] and nothing else. " +
            "You will then receive the image and can answer normally. " +
            "You cannot tap, scroll or control other apps; say so briefly if asked, " +
            "and offer the text the user can insert instead."

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
