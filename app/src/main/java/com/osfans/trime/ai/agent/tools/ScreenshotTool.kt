/*
 * SPDX-FileCopyrightText: 2026 Sprime contributors
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

package com.osfans.trime.ai.agent.tools

import com.osfans.trime.ai.agent.AiTool
import com.osfans.trime.ai.agent.ToolResult
import org.json.JSONObject

/** Captures the screen; the image is attached to the conversation by the caller. */
class ScreenshotTool(
    private val capture: suspend () -> String?,
) : AiTool {
    override val name = "take_screenshot"

    override val description = "截取当前屏幕，用来查看界面布局或图片内容"

    override val parameters = """
        {"type":"object","properties":{},"required":[]}
    """.trimIndent()

    override suspend fun execute(args: JSONObject): ToolResult {
        val image = capture() ?: return ToolResult("截图失败")
        return ToolResult("截图已附上", image)
    }
}
