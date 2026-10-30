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

/** Writes into the focused input field. */
class TypeTool : AiTool {
    override val name = "type_text"

    override val description = "在当前的输入框里写入文字"

    override val dangerous = true

    override val parameters = """
        {"type":"object","properties":{
          "text":{"type":"string","description":"要写入的内容"}
        },"required":["text"]}
    """.trimIndent()

    override suspend fun execute(args: JSONObject): ToolResult {
        if (!SprimeAccessibilityService.isConnected) return ToolResult("无障碍服务未开启")
        val text = args.optString("text")
        if (text.isEmpty()) return ToolResult("需要提供 text")
        val ok = SprimeActions.setText(text)
        return ToolResult(if (ok) "已写入 " + text.length + " 个字" else "没有找到可编辑的输入框，或该输入框是密码框")
    }
}
