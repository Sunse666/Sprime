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

/** Clicks an element by text, falling back to absolute coordinates. */
class ClickTool : AiTool {
    override val name = "click"

    override val description = "点击界面上的元素：优先用文字，找不到时用坐标"

    override val parameters = """
        {"type":"object","properties":{
          "text":{"type":"string","description":"要点击的文字或按钮文案"},
          "x":{"type":"integer","description":"屏幕横坐标"},
          "y":{"type":"integer","description":"屏幕纵坐标"}
        },"required":[]}
    """.trimIndent()

    override suspend fun execute(args: JSONObject): ToolResult {
        if (!SprimeAccessibilityService.isConnected) return ToolResult("无障碍服务未开启")
        val text = args.optString("text").trim()
        if (text.isNotEmpty()) {
            return if (SprimeActions.clickByText(text)) {
                ToolResult("已点击「" + text + "」")
            } else {
                ToolResult("没有找到「" + text + "」")
            }
        }
        if (args.has("x") && args.has("y")) {
            val ok = SprimeActions.tap(args.optDouble("x").toFloat(), args.optDouble("y").toFloat())
            return ToolResult(if (ok) "已点击坐标" else "点击失败")
        }
        return ToolResult("需要提供 text 或 x/y")
    }
}
