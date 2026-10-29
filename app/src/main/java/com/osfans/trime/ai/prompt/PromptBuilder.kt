/*
 * SPDX-FileCopyrightText: 2026 Sprime contributors
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

package com.osfans.trime.ai.prompt

import com.osfans.trime.ai.context.EditorContext

object PromptBuilder {
    private const val MAX_CONTENT = 4000
    private const val MAX_SYSTEM = 4000

    fun systemMessage(system: String): String = system.ifBlank { DefaultPrompts.SYSTEM }.trim().take(MAX_SYSTEM)

    fun build(
        instruction: String,
        content: String,
    ): String = instruction.ifBlank { DefaultPrompts.TRANSLATE } + "\n\n" + content.trim().take(MAX_CONTENT)

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
