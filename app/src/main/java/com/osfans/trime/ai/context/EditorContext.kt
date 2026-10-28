/*
 * SPDX-FileCopyrightText: 2026 Sprime contributors
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

package com.osfans.trime.ai.context

data class EditorContext(
    val selection: String?,
    val textBefore: String,
    val textAfter: String,
    val isPassword: Boolean,
    val packageName: String,
) {
    /** Text an action should operate on: the selection, or what precedes the cursor. */
    val content: String?
        get() = selection?.takeIf { it.isNotBlank() } ?: textBefore.takeIf { it.isNotBlank() }

    val hasContent: Boolean
        get() = !content.isNullOrBlank()
}
