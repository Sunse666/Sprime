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

/** Scrolls the current page. */
class ScrollTool : AiTool {
    override val name = "scroll"

    override val description = "上下左右滑动当前页面"

    override val parameters = """
        {"type":"object","properties":{
          "direction":{"type":"string","enum":["up","down","left","right"]},
          "distance":{"type":"integer","description":"滑动距离，像素"}
        },"required":["direction"]}
    """.trimIndent()

    override suspend fun execute(args: JSONObject): ToolResult {
        if (!SprimeAccessibilityService.isConnected) return ToolResult("无障碍服务未开启")
        val direction = args.optString("direction", "down")
        val distance = args.optInt("distance", 600)
        val ok = SprimeActions.swipe(direction, distance)
        return ToolResult(if (ok) "已向 " + direction + " 滑动" else "滑动失败")
    }
}
