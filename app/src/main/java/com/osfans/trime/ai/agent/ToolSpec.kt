/*
 * SPDX-FileCopyrightText: 2026 Sprime contributors
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

package com.osfans.trime.ai.agent

import com.osfans.trime.ai.model.ChatMessage
import org.json.JSONObject

/** Result of one tool execution. */
data class ToolResult(
    val text: String,
    val image: String? = null,
) {
    fun toMessage(callId: String, name: String): List<ChatMessage> {
        val messages = mutableListOf(ChatMessage(com.osfans.trime.ai.model.ChatRole.TOOL, text, toolCallId = callId, name = name))
        val img = image
        if (!img.isNullOrEmpty()) {
            messages += ChatMessage(
                com.osfans.trime.ai.model.ChatRole.USER,
                "（这是工具 $name 刚截取的屏幕图像，请结合上图与上方工具结果作答）",
                image = img,
            )
        }
        return messages
    }
}

/** One callable capability exposed to the model. */
interface AiTool {
    val name: String
    val description: String
    /** JSON schema object describing the arguments. */
    val parameters: String
    /** Dangerous tools ask for confirmation when the policy requires it. */
    val dangerous: Boolean
        get() = false

    suspend fun execute(args: JSONObject): ToolResult
}

/** Serialized form sent in the request body. */
data class ToolSpec(
    val name: String,
    val description: String,
    val parameters: JSONObject,
) {
    companion object {
        fun of(tool: AiTool): ToolSpec =
            ToolSpec(tool.name, tool.description, runCatching { JSONObject(tool.parameters) }.getOrElse { JSONObject() })
    }
}

data class ToolCall(
    val id: String,
    val name: String,
    val arguments: String,
)
