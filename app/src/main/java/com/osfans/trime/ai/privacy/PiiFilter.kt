/*
 * SPDX-FileCopyrightText: 2026 Sprime contributors
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

package com.osfans.trime.ai.privacy

/**
 * Masks common personal identifiers before text leaves the device.
 * Patterns are intentionally conservative to avoid mangling normal prose.
 */
object PiiFilter {
    data class Options(
        val phone: Boolean = true,
        val idCard: Boolean = true,
        val bankCard: Boolean = true,
        val email: Boolean = false,
    ) {
        val anyEnabled: Boolean
            get() = phone || idCard || bankCard || email
    }

    private val PHONE = Regex("(?<!\\d)1[3-9]\\d{9}(?!\\d)")
    private val ID_CARD = Regex("(?<!\\d)\\d{17}[\\dXx](?!\\d)")
    private val BANK_CARD = Regex("(?<!\\d)\\d{16,19}(?!\\d)")
    private val EMAIL = Regex("[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}")

    fun sanitize(
        text: String,
        options: Options,
    ): String {
        if (!options.anyEnabled || text.isEmpty()) return text
        var out = text
        if (options.email) out = out.replace(EMAIL, "[email]")
        if (options.idCard) out = out.replace(ID_CARD, "[id]")
        if (options.bankCard) out = out.replace(BANK_CARD, "[bank]")
        if (options.phone) out = out.replace(PHONE, "[phone]")
        return out
    }
}
