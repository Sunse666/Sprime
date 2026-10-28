/*
 * SPDX-FileCopyrightText: 2026 Sprime contributors
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

package com.osfans.trime.ai.prompt

import io.kotest.core.spec.style.StringSpec
import io.kotest.matchers.shouldBe

class InsertParserTest :
    StringSpec({
        "keeps plain answers untouched" {
            val parsed = InsertParser.parse("only text")
            parsed.display shouldBe "only text"
            parsed.insert shouldBe null
        }

        "extracts the insert block" {
            val parsed = InsertParser.parse("reply:\n<insert>ok, see you</insert>")
            parsed.insert shouldBe "ok, see you"
            parsed.display shouldBe "reply:\nok, see you"
        }

        "ignores an empty insert block" {
            val parsed = InsertParser.parse("nothing<insert>  </insert>")
            parsed.insert shouldBe null
        }

        "handles multiline blocks" {
            val parsed = InsertParser.parse("<insert>line1\nline2</insert>")
            parsed.insert shouldBe "line1\nline2"
        }
    })
