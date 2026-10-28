/*
 * SPDX-FileCopyrightText: 2026 Sprime contributors
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

package com.osfans.trime.ai.access

import android.accessibilityservice.AccessibilityService
import android.view.accessibility.AccessibilityEvent
import android.view.accessibility.AccessibilityNodeInfo

/**
 * Read-only accessibility service. It never performs actions or gestures, it
 * only exposes the text of the window that currently has focus.
 */
class ScreenReaderService : AccessibilityService() {
    companion object {
        @Volatile
        private var current: ScreenReaderService? = null

        val isConnected: Boolean
            get() = current != null

        fun readScreen(limit: Int = 4000): String? = current?.capture(limit)
    }

    override fun onServiceConnected() {
        current = this
    }

    override fun onAccessibilityEvent(event: AccessibilityEvent?) = Unit

    override fun onInterrupt() = Unit

    override fun onDestroy() {
        current = null
        super.onDestroy()
    }

    private fun capture(limit: Int): String? {
        val window =
            windows.firstOrNull { it.isActive && it.root?.packageName != packageName }
                ?: windows.firstOrNull { it.root?.packageName != packageName }
        val root = window?.root ?: return null
        if (root.isPassword) return null
        val builder = StringBuilder()
        collect(root, builder, limit)
        return builder.toString().trim().ifEmpty { null }
    }

    private fun collect(
        node: AccessibilityNodeInfo?,
        builder: StringBuilder,
        limit: Int,
    ) {
        if (node == null || builder.length >= limit) return
        if (node.isPassword) return
        val button = node.className?.toString()?.contains("Button") == true
        val values =
            if (button) {
                emptyList()
            } else {
                listOf(
                    node.text?.toString()?.trim(),
                    node.contentDescription?.toString()?.trim(),
                )
            }
        for (value in values) {
            if (value.isNullOrEmpty() || value.length < 2) continue
            if (builder.contains(value)) continue
            builder.append(value).append('\n')
            if (builder.length >= limit) return
        }
        for (index in 0 until node.childCount) {
            collect(node.getChild(index), builder, limit)
            if (builder.length >= limit) return
        }
    }
}
