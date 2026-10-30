/*
 * SPDX-FileCopyrightText: 2026 Sprime contributors
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

package com.osfans.trime.ai.agent.tools

import com.osfans.trime.ai.agent.AiTool
import com.osfans.trime.ai.agent.ToolResult
import com.sprime.ime.access.SprimeAccessibilityService
import org.json.JSONObject

/** Reads the visible text of the foreground window. */
class ReadScreenTool : AiTool {
    override val name = "read_screen"

    override val description = "读取当前屏幕上的文字内容，用来了解界面"

    override val parameters = """
        {"type":"object","properties":{},"required":[]}
    """.trimIndent()

    override suspend fun execute(args: JSONObject): ToolResult {
        if (!SprimeAccessibilityService.isConnected) {
            return ToolResult("无障碍服务未开启，无法读取屏幕")
        }
        val text = SprimeAccessibilityService.readScreen()
        return ToolResult(text?.takeIf { it.isNotBlank() } ?: "屏幕上没有可读文字")
    }
}
