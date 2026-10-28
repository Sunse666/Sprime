/*
 * SPDX-FileCopyrightText: 2026 Sprime contributors
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

package com.osfans.trime.ai.prompt

import com.osfans.trime.ai.context.EditorContext

object PromptBuilder {
    private const val MAX_CONTENT = 2000

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
