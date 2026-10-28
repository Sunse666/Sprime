/*
 * SPDX-FileCopyrightText: 2026 Sprime contributors
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

package com.osfans.trime.ai.provider

import io.kotest.core.spec.style.StringSpec
import io.kotest.matchers.shouldBe

class SseParserTest :
    StringSpec({
        "returns the payload when a blank line closes an event" {
            val parser = SseParser()
            parser.feed("data: {\"a\":1}") shouldBe null
            parser.feed("") shouldBe "{\"a\":1}"
        }

        "joins multiple data lines with newlines" {
            val parser = SseParser()
            parser.feed("data: first")
            parser.feed("data: second")
            parser.feed("") shouldBe "first\nsecond"
        }

        "ignores comment and unknown fields" {
            val parser = SseParser()
            parser.feed(": keep-alive") shouldBe null
            parser.feed("event: message") shouldBe null
            parser.feed("data: payload")
            parser.feed("") shouldBe "payload"
        }

        "blank line without data yields nothing" {
            SseParser().feed("") shouldBe null
        }

        "keeps the done marker intact" {
            val parser = SseParser()
            parser.feed("data: [DONE]")
            parser.feed("") shouldBe "[DONE]"
        }
    })
