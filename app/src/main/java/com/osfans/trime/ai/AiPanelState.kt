/*
 * SPDX-FileCopyrightText: 2026 Sprime contributors
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

package com.osfans.trime.ai

sealed interface AiPanelState {
    data object Idle : AiPanelState

    data class Streaming(
        val text: String,
        val thinking: String = "",
    ) : AiPanelState

    data class Done(
        val text: String,
        val thinking: String = "",
        val insertText: String? = null,
    ) : AiPanelState

    data class Error(val message: String) : AiPanelState

    data class Inserted(val text: String) : AiPanelState
}
