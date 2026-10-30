/*
 * SPDX-FileCopyrightText: 2026 Sprime contributors
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

package com.sprime.ime.strip

import io.kotest.core.spec.style.StringSpec
import io.kotest.matchers.shouldBe

class StripLogicTest :
    StringSpec({
        "parses answers written in different formats" {
            StripAnswerParser.parse("1A\n2.C\n3：B\n4、√\n5 X") shouldBe
                listOf(1 to "A", 2 to "C", 3 to "B", 4 to "√", 5 to "X")
        }

        "parses answers scattered inside a sentence" {
            StripAnswerParser.parse("第 1 题选 A，第 2 题选 c") shouldBe listOf(1 to "A", 2 to "C")
        }

        "returns null when nothing looks like an answer" {
            StripAnswerParser.parse("我不确定这些题目") shouldBe null
        }

        "caps the answer list at twenty entries" {
            val raw = (1..30).joinToString("\n") { "" + it + "A" }
            StripAnswerParser.parse(raw)?.size shouldBe 20
        }

        "slots map to rules and can be cleared" {
            val rule = StripState.defaultRules().first()
            val bound = StripState().withSlot(3, rule.id)
            bound.ruleFor(3)?.name shouldBe rule.name
            bound.ruleFor(4) shouldBe null
            bound.withSlot(3, null).ruleFor(3) shouldBe null
        }

        "old rule json without the new fields still decodes" {
            val json =
                """{"id":"r1","name":"n","prompt":"p","readScreen":true,""" +
                    """"useScreenshot":false,"resultMode":"ANSWER_TABLE","maxChars":12000}"""
            val state = kotlinx.serialization.json.Json { ignoreUnknownKeys = true }
                .decodeFromString<StripRule>(json)
            state.useTools shouldBe true
            state.maxOutputChars shouldBe 2000
        }
    })
