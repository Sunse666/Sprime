/*
 * SPDX-FileCopyrightText: 2026 Sprime contributors
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

package com.osfans.trime.ai.provider

/**
 * Minimal server-sent events parser: feed one line at a time, get a payload
 * back when an event is complete. Comment lines and other fields are ignored.
 */
class SseParser {
    private val data = StringBuilder()

    fun feed(line: String): String? {
        if (line.isEmpty()) {
            return flush()
        }
        if (line.startsWith(":")) {
            return null
        }
        if (line.startsWith("data:")) {
            val value = line.removePrefix("data:").trimStart()
            if (data.isNotEmpty()) data.append('\n')
            data.append(value)
        }
        return null
    }

    fun flush(): String? {
        if (data.isEmpty()) return null
        val payload = data.toString().trim()
        data.clear()
        return payload.ifEmpty { null }
    }
}
