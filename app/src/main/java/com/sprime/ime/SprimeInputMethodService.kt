/*
 * SPDX-FileCopyrightText: 2026 Sprime contributors
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

package com.sprime.ime

import com.osfans.trime.ime.core.TrimeInputMethodService

/**
 * Neutral entry point registered in the manifest, so IME enumeration does not
 * expose the upstream fork package name.
 */
class SprimeInputMethodService : TrimeInputMethodService()
