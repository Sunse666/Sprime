/*
 * SPDX-FileCopyrightText: 2026 Sprime contributors
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

package com.osfans.trime.ai.prompt

import io.kotest.core.spec.style.StringSpec
import io.kotest.matchers.shouldBe
import io.kotest.matchers.string.shouldContain

class PromptBuilderTest :
    StringSpec({
        val chinese = Regex("[\u4e00-\u9fa5]")

        "system prompt is chinese and mentions the tools" {
            val prompt = PromptBuilder.systemMessage("")
            chinese.containsMatchIn(prompt) shouldBe true
            prompt shouldContain "<insert>"
            prompt shouldContain "describe_screen"
        }

        "a user provided system prompt replaces the default" {
            PromptBuilder.systemMessage("自定义") shouldBe "自定义"
        }

        "every action instruction is chinese" {
            AiAction.entries.forEach { action ->
                chinese.containsMatchIn(action.defaultInstruction) shouldBe true
            }
        }

        "action prompt keeps the content after the instruction" {
            PromptBuilder.build(DefaultPrompts.TRANSLATE, " hello ") shouldBe
                DefaultPrompts.TRANSLATE + "\n\nhello"
        }
    })
