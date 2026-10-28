/*
 * SPDX-FileCopyrightText: 2026 Sprime contributors
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

package com.osfans.trime.ai.prompt

/** Detects questions that explicitly ask for a look at the current screen. */
object ScreenHints {
    private val HINTS =
        listOf("截图", "截屏", "截个图", "截一下", "屏幕", "screenshot", "screen")

    fun matches(text: String): Boolean = HINTS.any { text.contains(it, ignoreCase = true) }
}
