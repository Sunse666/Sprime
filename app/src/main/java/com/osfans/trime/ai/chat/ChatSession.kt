/*
 * SPDX-FileCopyrightText: 2026 Sprime contributors
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

package com.osfans.trime.ai.chat

import com.osfans.trime.ai.model.ChatMessage
import com.osfans.trime.ai.model.ChatRole

/**
 * Keeps the current conversation so follow-up questions keep their context.
 * The system prompt is rebuilt from settings on every request.
 */
class ChatSession(
    private val systemPrompt: () -> String,
) {
    companion object {
        private const val MAX_MESSAGES = 20
        private const val MAX_CHARS = 8000
    }

    private val history = mutableListOf<ChatMessage>()

    val hasUserTurn: Boolean
        get() = history.any { it.role == ChatRole.USER }

    fun reset() {
        history.clear()
    }

    fun addUser(
        text: String,
        image: String? = null,
    ) {
        history += ChatMessage(ChatRole.USER, text, image)
        trim()
    }

    fun addAssistant(
        text: String,
        toolCalls: String? = null,
    ) {
        history += ChatMessage(ChatRole.ASSISTANT, text, toolCalls = toolCalls)
        trim()
    }

    fun addMessage(message: ChatMessage) {
        history += message
        trim()
    }

    fun history(): List<ChatMessage> = history.toList()

    /** Plain text transcript of the conversation, used by the panel. */
    fun transcript(): String = history.joinToString("\n\n") { message ->
        val prefix = if (message.role == ChatRole.USER) "你：" else "AI："
        prefix + message.content.trim()
    }

    fun messages(): List<ChatMessage> {
        val system = systemPrompt().trim()
        return if (system.isEmpty()) {
            history.toList()
        } else {
            listOf(ChatMessage(ChatRole.SYSTEM, system)) + history
        }
    }

    private fun trim() {
        while (history.size > MAX_MESSAGES) {
            history.removeAt(0)
        }
        while (history.sumOf { it.content.length } > MAX_CHARS && history.size > 2) {
            history.removeAt(0)
        }
    }
}
