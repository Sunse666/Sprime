/*
 * SPDX-FileCopyrightText: 2026 Sprime contributors
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

package com.osfans.trime.ai.prompt

import com.osfans.trime.ai.context.EditorContext

object PromptBuilder {
    private const val MAX_CONTENT = 2000
    private const val MAX_PERSONA = 2000

    private val BASE_PROMPT =
        "You are Sprime, an assistant built into an Android keyboard. " +
            "The user is typing in another app and may ask you to translate, rewrite or answer. " +
            "Keep answers short. When the task is to rewrite or translate text, " +
            "output only the result without explanations."

    fun systemMessage(
        persona: String,
        extra: String,
    ): String = buildString {
        append(BASE_PROMPT)
        if (persona.isNotBlank()) {
            append("\n\n[Persona]\n")
            append(persona.trim().take(MAX_PERSONA))
        }
        if (extra.isNotBlank()) {
            append("\n\n")
            append(extra.trim().take(MAX_PERSONA))
        }
    }

    fun build(
        action: AiAction,
        context: EditorContext,
    ): String {
        val content = context.content.orEmpty().trim().take(MAX_CONTENT)
        return action.instruction + "\n\n" + content
    }

    fun buildCustom(
        question: String,
        context: EditorContext,
    ): String {
        val content = context.selection?.trim()?.take(MAX_CONTENT)
        return if (content.isNullOrEmpty()) {
            question
        } else {
            question + "\n\n---\n" + content
        }
    }
}
