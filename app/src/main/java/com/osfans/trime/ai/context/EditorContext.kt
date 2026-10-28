/*
 * SPDX-FileCopyrightText: 2026 Sprime contributors
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

package com.osfans.trime.ai.context

data class EditorContext(
    val selection: String?,
    val textBefore: String,
    val textAfter: String,
    val fieldText: String,
    val clipboardText: String,
    val isPassword: Boolean,
    val packageName: String,
) {
    /**
     * Text an action should operate on: the selection, then the whole field,
     * then what precedes the cursor, then the clipboard.
     */
    val content: String?
        get() =
            selection?.takeIf { it.isNotBlank() }
                ?: fieldText.takeIf { it.isNotBlank() }
                ?: textBefore.takeIf { it.isNotBlank() }
                ?: clipboardText.takeIf { it.isNotBlank() }

    val hasContent: Boolean
        get() = !content.isNullOrBlank()
}
