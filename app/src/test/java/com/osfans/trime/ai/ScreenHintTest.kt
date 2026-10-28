/*
 * SPDX-FileCopyrightText: 2026 Sprime contributors
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

package com.osfans.trime.ai.prompt

import io.kotest.core.spec.style.StringSpec
import io.kotest.matchers.shouldBe

class ScreenHintTest :
    StringSpec({
        "detects chinese screenshot requests" {
            ScreenHints.matches("帮我截个图看看") shouldBe true
            ScreenHints.matches("截屏看一下这个页面") shouldBe true
            ScreenHints.matches("看看屏幕上写的什么") shouldBe true
        }

        "detects english screenshot requests" {
            ScreenHints.matches("take a screenshot") shouldBe true
            ScreenHints.matches("what is on my screen") shouldBe true
        }

        "ignores ordinary questions" {
            ScreenHints.matches("帮我翻译这句话") shouldBe false
            ScreenHints.matches("你好") shouldBe false
        }
    })
