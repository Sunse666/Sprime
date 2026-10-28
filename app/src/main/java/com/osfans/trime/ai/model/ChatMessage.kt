/*
 * SPDX-FileCopyrightText: 2026 Sprime contributors
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

package com.osfans.trime.ai.model

enum class ChatRole(val wireName: String) {
    SYSTEM("system"),
    USER("user"),
    ASSISTANT("assistant"),
}

data class ChatMessage(
    val role: ChatRole,
    val content: String,
)
