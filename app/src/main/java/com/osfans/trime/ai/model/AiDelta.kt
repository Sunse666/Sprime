/*
 * SPDX-FileCopyrightText: 2026 Sprime contributors
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

package com.osfans.trime.ai.model

sealed interface AiDelta {
    data class Text(val value: String) : AiDelta

    data class Reasoning(val value: String) : AiDelta

    /** Emitted once per response, carrying the raw JSON array of tool calls. */
    data class ToolCalls(val json: String) : AiDelta

    data object Done : AiDelta

    data class Failure(val message: String) : AiDelta
}
