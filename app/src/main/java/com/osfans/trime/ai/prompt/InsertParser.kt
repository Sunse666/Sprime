/*
 * SPDX-FileCopyrightText: 2026 Sprime contributors
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

package com.osfans.trime.ai.prompt

/**
 * The model marks the text that belongs in the input box with an <insert> block,
 * so commentary never ends up in the editor.
 */
object InsertParser {
    private val BLOCK = Regex("<insert>([\\s\\S]*?)</insert>", RegexOption.IGNORE_CASE)

    data class Parsed(
        val display: String,
        val insert: String?,
    )

    fun parse(text: String): Parsed {
        val match = BLOCK.find(text) ?: return Parsed(text.trim(), null)
        val insert = match.groupValues[1].trim().ifEmpty { null }
        val display = text.replace(BLOCK, insert.orEmpty()).trim()
        return Parsed(display, insert)
    }
}
