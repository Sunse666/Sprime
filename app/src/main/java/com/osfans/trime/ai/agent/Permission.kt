/*
 * SPDX-FileCopyrightText: 2026 Sprime contributors
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

package com.osfans.trime.ai.agent

/** Per tool permission, mirroring the settings screen. */
enum class PermissionLevel {
    ALLOW,
    ASK,
    FORBID,
    ;

    companion object {
        fun parse(raw: String): PermissionLevel? = entries.firstOrNull { it.name.equals(raw, true) }
    }
}

/** How much the assistant is allowed to do on its own. */
enum class ApprovalPolicy {
    /** Ask before every single tool call. */
    EVERY_STEP,

    /** Ask only for tools marked dangerous. */
    DANGEROUS_ONLY,

    /** Never ask. */
    AUTO,
    ;

    companion object {
        fun parse(raw: String): ApprovalPolicy? = entries.firstOrNull { it.name.equals(raw, true) }
    }
}

/** Pending confirmation shown in the AI panel. */
data class ApprovalRequest(
    val tool: String,
    val summary: String,
)
