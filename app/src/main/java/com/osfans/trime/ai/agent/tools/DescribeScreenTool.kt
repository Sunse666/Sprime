/*
 * SPDX-FileCopyrightText: 2026 Sprime contributors
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

package com.osfans.trime.ai.agent.tools

import com.osfans.trime.ai.agent.AiTool
import com.osfans.trime.ai.agent.ToolResult
import com.sprime.ime.access.SprimeAccessibilityService
import com.sprime.ime.access.SprimeActions
import org.json.JSONObject

/** Screen dump with element coordinates, used before clicking. */
class DescribeScreenTool : AiTool {
    override val name = "describe_screen"

    override val description = "列出当前界面上的元素、文字和坐标，点击前先调用它"

    override val parameters = """
        {"type":"object","properties":{},"required":[]}
    """.trimIndent()

    override suspend fun execute(args: JSONObject): ToolResult {
        if (!SprimeAccessibilityService.isConnected) return ToolResult("无障碍服务未开启")
        val text = SprimeActions.describeScreen()
        return ToolResult(text ?: "屏幕上没有可读元素")
    }
}
