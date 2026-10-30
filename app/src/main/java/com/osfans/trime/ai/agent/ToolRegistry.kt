/*
 * SPDX-FileCopyrightText: 2026 Sprime contributors
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

package com.osfans.trime.ai.agent

import com.osfans.trime.ai.agent.tools.ClickTool
import com.osfans.trime.ai.agent.tools.DescribeScreenTool
import com.osfans.trime.ai.agent.tools.GestureTool
import com.osfans.trime.ai.agent.tools.ReadScreenTool
import com.osfans.trime.ai.agent.tools.ScreenshotTool
import com.osfans.trime.ai.agent.tools.ScrollTool
import com.osfans.trime.ai.agent.tools.TypeTool
import org.json.JSONObject

/** Holds the tools that are currently available to the model. */
class ToolRegistry(
    private val screenshot: suspend () -> String?,
) {
    private val tools = LinkedHashMap<String, AiTool>()

    init {
        register(ReadScreenTool())
        register(DescribeScreenTool())
        register(ScreenshotTool(screenshot))
        register(ClickTool())
        register(ScrollTool())
        register(TypeTool())
        register(GestureTool())
    }

    fun register(tool: AiTool) {
        tools[tool.name] = tool
    }

    fun specs(): List<ToolSpec> = tools.values.map(ToolSpec::of)

    fun find(name: String): AiTool? = tools[name]

    suspend fun execute(call: ToolCall): ToolResult {
        val tool = tools[call.name] ?: return ToolResult("错误：没有名为 ${call.name} 的工具")
        val args = runCatching { JSONObject(call.arguments.ifBlank { "{}" }) }.getOrElse { JSONObject() }
        return runCatching { tool.execute(args) }
            .getOrElse { ToolResult("工具执行失败：${it.message}") }
    }
}
