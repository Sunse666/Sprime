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

/** System navigation actions. */
class GestureTool : AiTool {
    override val name = "gesture"

    override val description = "执行系统操作：返回、回到桌面、最近任务、通知栏"

    override val dangerous = true

    override val parameters = """
        {"type":"object","properties":{
          "action":{"type":"string","enum":["back","home","recents","notifications"]}
        },"required":["action"]}
    """.trimIndent()

    override suspend fun execute(args: JSONObject): ToolResult {
        if (!SprimeAccessibilityService.isConnected) return ToolResult("无障碍服务未开启")
        val action = args.optString("action")
        val ok = SprimeActions.globalAction(action)
        return ToolResult(if (ok) "已执行 " + action else "不支持的操作：" + action)
    }
}
