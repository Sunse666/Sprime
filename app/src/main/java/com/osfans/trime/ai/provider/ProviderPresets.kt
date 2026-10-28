/*
 * SPDX-FileCopyrightText: 2026 Sprime contributors
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

package com.osfans.trime.ai.provider

data class ProviderPreset(
    val id: String,
    val label: String,
    val baseUrl: String,
    val model: String,
)

object ProviderPresets {
    const val DEFAULT_ID = "deepseek"

    val all: List<ProviderPreset> =
        listOf(
            ProviderPreset("deepseek", "DeepSeek", "https://api.deepseek.com/v1", "deepseek-chat"),
            ProviderPreset("openai", "OpenAI", "https://api.openai.com/v1", "gpt-4o-mini"),
            ProviderPreset("moonshot", "Kimi", "https://api.moonshot.cn/v1", "moonshot-v1-8k"),
            ProviderPreset("zhipu", "智谱 GLM", "https://open.bigmodel.cn/api/paas/v4", "glm-4-flash"),
            ProviderPreset(
                "dashscope",
                "通义千问",
                "https://dashscope.aliyuncs.com/compatible-mode/v1",
                "qwen-plus",
            ),
            ProviderPreset("openrouter", "OpenRouter", "https://openrouter.ai/api/v1", ""),
            ProviderPreset("ollama", "Ollama (本地)", "http://127.0.0.1:11434/v1", "qwen2.5:7b"),
            ProviderPreset("custom", "自定义", "", ""),
        )

    fun find(id: String): ProviderPreset = all.firstOrNull { it.id == id } ?: all.first()
}
