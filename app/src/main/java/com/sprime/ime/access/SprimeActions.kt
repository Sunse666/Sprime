/*
 * SPDX-FileCopyrightText: 2026 Sprime contributors
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

package com.sprime.ime.access

import android.accessibilityservice.AccessibilityService
import android.accessibilityservice.GestureDescription
import android.graphics.Path
import android.graphics.Rect
import android.os.Build
import android.os.Bundle
import android.view.accessibility.AccessibilityNodeInfo

/**
 * Actions the AI agent may perform through the accessibility service. Every call is
 * gated by the approval policy before reaching this object.
 */
object SprimeActions {
    fun activeRoot(): AccessibilityNodeInfo? =
        SprimeAccessibilityService.instance?.let { service ->
            service.windows.firstOrNull { it.isActive && it.root?.packageName != service.packageName }?.root
                ?: service.windows.firstOrNull { it.root?.packageName != service.packageName }?.root
                ?: service.rootInActiveWindow?.takeIf { it.packageName != service.packageName }
        }

    fun clickByText(target: String): Boolean {
        val node = findNode(target) ?: return false
        var candidate: AccessibilityNodeInfo? = node
        while (candidate != null) {
            if (candidate.isClickable && candidate.performAction(AccessibilityNodeInfo.ACTION_CLICK)) return true
            candidate = candidate.parent
        }
        val bounds = Rect()
        node.getBoundsInScreen(bounds)
        return tap(bounds.centerX().toFloat(), bounds.centerY().toFloat())
    }

    fun tap(
        x: Float,
        y: Float,
    ): Boolean {
        val service = SprimeAccessibilityService.instance ?: return false
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.N) return false
        val path = Path().apply { moveTo(x, y) }
        val gesture =
            GestureDescription.Builder()
                .addStroke(GestureDescription.StrokeDescription(path, 0, 60))
                .build()
        return service.dispatchGesture(gesture, null, null)
    }

    fun swipe(
        direction: String,
        distance: Int,
    ): Boolean {
        val service = SprimeAccessibilityService.instance ?: return false
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.N) return false
        val metrics = service.resources.displayMetrics
        val cx = metrics.widthPixels / 2f
        val cy = metrics.heightPixels / 2f
        val d = distance.toFloat().coerceIn(100f, metrics.heightPixels / 2f)
        val (sx, sy, ex, ey) =
            when (direction.lowercase()) {
                "up" -> listOf(cx, cy + d / 2, cx, cy - d / 2)
                "left" -> listOf(cx + d / 2, cy, cx - d / 2, cy)
                "right" -> listOf(cx - d / 2, cy, cx + d / 2, cy)
                else -> listOf(cx, cy - d / 2, cx, cy + d / 2)
            }
        val path = Path().apply {
            moveTo(sx, sy)
            lineTo(ex, ey)
        }
        val gesture =
            GestureDescription.Builder()
                .addStroke(GestureDescription.StrokeDescription(path, 0, 220))
                .build()
        return service.dispatchGesture(gesture, null, null)
    }

    fun setText(text: String): Boolean {
        val root = activeRoot() ?: return false
        val focused = root.findFocus(AccessibilityNodeInfo.FOCUS_INPUT) ?: return false
        if (focused.isPassword) return false
        val args = Bundle().apply {
            putCharSequence(AccessibilityNodeInfo.ACTION_ARGUMENT_SET_TEXT_CHARSEQUENCE, text)
        }
        if (focused.performAction(AccessibilityNodeInfo.ACTION_SET_TEXT, args)) return true
        focused.performAction(AccessibilityNodeInfo.ACTION_FOCUS)
        return focused.performAction(AccessibilityNodeInfo.ACTION_SET_TEXT, args)
    }

    fun globalAction(action: String): Boolean {
        val service = SprimeAccessibilityService.instance ?: return false
        val id =
            when (action.lowercase()) {
                "back" -> AccessibilityService.GLOBAL_ACTION_BACK
                "home" -> AccessibilityService.GLOBAL_ACTION_HOME
                "recents" -> AccessibilityService.GLOBAL_ACTION_RECENTS
                "notifications" -> AccessibilityService.GLOBAL_ACTION_NOTIFICATIONS
                else -> return false
            }
        return service.performGlobalAction(id)
    }

    fun describeScreen(limit: Int = 4000): String? {
        val root = activeRoot() ?: return null
        if (root.isPassword) return null
        val builder = StringBuilder()
        describe(root, builder, limit)
        return builder.toString().trim().ifEmpty { null }
    }

    private fun findNode(target: String): AccessibilityNodeInfo? {
        val root = activeRoot() ?: return null
        val queue = ArrayDeque<AccessibilityNodeInfo>()
        queue.add(root)
        var best: AccessibilityNodeInfo? = null
        while (queue.isNotEmpty()) {
            val node = queue.removeFirst()
            val text = node.text?.toString()?.trim().orEmpty()
            val desc = node.contentDescription?.toString()?.trim().orEmpty()
            if (text.isNotEmpty() || desc.isNotEmpty()) {
                if (text == target || desc == target) return node
                if (best == null && (text.contains(target, true) || desc.contains(target, true))) best = node
            }
            for (i in 0 until node.childCount) node.getChild(i)?.let(queue::add)
        }
        return best
    }

    private fun describe(
        node: AccessibilityNodeInfo?,
        builder: StringBuilder,
        limit: Int,
    ) {
        if (node == null || builder.length >= limit) return
        if (node.isPassword) return
        val text = node.text?.toString()?.trim().orEmpty()
        val desc = node.contentDescription?.toString()?.trim().orEmpty()
        val label = text.ifEmpty { desc }
        if (label.isNotEmpty()) {
            val bounds = Rect()
            node.getBoundsInScreen(bounds)
            val clickable = if (node.isClickable) " [可点]" else ""
            builder
                .append(label.take(80))
                .append(" @")
                .append(bounds.centerX())
                .append(',')
                .append(bounds.centerY())
                .append(clickable)
                .append('\n')
            if (builder.length >= limit) return
        }
        for (i in 0 until node.childCount) describe(node.getChild(i), builder, limit)
    }
}
