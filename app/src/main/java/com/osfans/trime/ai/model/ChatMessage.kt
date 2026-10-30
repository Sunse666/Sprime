/*
 * SPDX-FileCopyrightText: 2026 Sprime contributors
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

package com.osfans.trime.ai.model

enum class ChatRole(val wireName: String) {
    SYSTEM("system"),
    USER("user"),
    ASSISTANT("assistant"),
    TOOL("tool"),
}

data class ChatMessage(
    val role: ChatRole,
    val content: String,
    /** Base64 JPEG that accompanies this message as an image part. */
    val image: String? = null,
    /** Raw JSON array of tool_calls produced by the assistant. */
    val toolCalls: String? = null,
    /** Identifier of the tool call this message answers. */
    val toolCallId: String? = null,
    /** Tool name, required by some providers on tool messages. */
    val name: String? = null,
)
