/*
 * SPDX-FileCopyrightText: 2026 Sprime contributors
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

package com.osfans.trime.ai.privacy

import io.kotest.core.spec.style.StringSpec
import io.kotest.matchers.shouldBe

class PiiFilterTest :
    StringSpec({
        val all = PiiFilter.Options(phone = true, idCard = true, bankCard = true, email = true)

        "masks phone numbers" {
            PiiFilter.sanitize("call 13800138000 now", all) shouldBe "call [phone] now"
        }

        "masks id cards" {
            PiiFilter.sanitize("id 11010519491231002X here", all) shouldBe "id [id] here"
        }

        "masks bank cards" {
            PiiFilter.sanitize("card 6222021234567890123 ok", all) shouldBe "card [bank] ok"
        }

        "masks emails" {
            PiiFilter.sanitize("mail me@example.com today", all) shouldBe "mail [email] today"
        }

        "keeps text untouched when disabled" {
            val off = PiiFilter.Options(false, false, false, false)
            PiiFilter.sanitize("13800138000", off) shouldBe "13800138000"
        }

        "does not touch ordinary numbers" {
            PiiFilter.sanitize("version 1.2.3 released in 2024", all) shouldBe
                "version 1.2.3 released in 2024"
        }
    })
