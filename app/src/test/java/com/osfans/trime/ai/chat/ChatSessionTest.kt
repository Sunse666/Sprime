/*
 * SPDX-FileCopyrightText: 2026 Sprime contributors
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

package com.osfans.trime.ai.chat

import io.kotest.core.spec.style.StringSpec
import io.kotest.matchers.shouldBe

class ChatSessionTest :
    StringSpec({
        "keeps every turn and formats the transcript" {
            val session = ChatSession { "" }
            session.addUser("第一问")
            session.addAssistant("第一答")
            session.addUser("第二问")
            session.addAssistant("第二答")

            session.history().size shouldBe 4
            session.transcript() shouldBe "你：第一问\n\nAI：第一答\n\n你：第二问\n\nAI：第二答"
        }

        "drops the oldest turns when the session grows" {
            val session = ChatSession { "" }
            repeat(15) { index ->
                session.addUser("问" + index)
                session.addAssistant("答" + index)
            }
            val history = session.history()
            (history.size <= 20) shouldBe true
            history.last().content shouldBe "答14"
        }

        "reset clears the transcript" {
            val session = ChatSession { "" }
            session.addUser("问")
            session.reset()
            session.history().isEmpty() shouldBe true
            session.transcript() shouldBe ""
        }
    })
