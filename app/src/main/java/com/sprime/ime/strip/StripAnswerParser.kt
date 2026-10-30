/*
 * SPDX-FileCopyrightText: 2026 Sprime contributors
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

package com.sprime.ime.strip

/** Parses answers like "1A" / "2.C" / "3：B" out of a model reply. */
object StripAnswerParser {
    const val MAX_ANSWERS = 20

    fun parse(raw: String): List<Pair<Int, String>>? {
        val found = LinkedHashMap<Int, String>()
        STRICT.findAll(raw).forEach { match ->
            if (found.size < MAX_ANSWERS) {
                match.groupValues[1].toIntOrNull()?.let { found[it] = match.groupValues[2].uppercase() }
            }
        }
        if (found.isEmpty()) {
            // Patterns like "第 3 题选 B".
            QUESTION.findAll(raw).forEach { match ->
                if (found.size < MAX_ANSWERS) {
                    match.groupValues[1].toIntOrNull()?.let { found.putIfAbsent(it, match.groupValues[2].uppercase()) }
                }
            }
        }
        if (found.isEmpty()) {
            LOOSE.findAll(raw).forEach { match ->
                if (found.size < MAX_ANSWERS) {
                    match.groupValues[1].toIntOrNull()?.let { found.putIfAbsent(it, match.groupValues[2].uppercase()) }
                }
            }
        }
        if (found.isEmpty()) return null
        return found.entries.sortedBy { it.key }.map { it.key to it.value }.take(MAX_ANSWERS)
    }

    private val STRICT = Regex("(?m)^\\s*(\\d{1,2})\\s*[.、:：]?\\s*([A-Ea-e√×]|X|x)\\s*$")
    private val LOOSE = Regex("([0-9]{1,2})\\s*([A-Ea-e√×])")
    private val QUESTION = Regex("第\\s*(\\d{1,2})\\s*题[^A-Ea-e√×\\n]{0,10}([A-Ea-e√×])")
}
