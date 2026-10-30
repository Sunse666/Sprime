/*
 * SPDX-FileCopyrightText: 2026 Sprime contributors
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

package com.sprime.ime.access

import android.accessibilityservice.AccessibilityService
import android.graphics.Bitmap
import android.os.Build
import android.util.Base64
import android.view.Display
import android.view.accessibility.AccessibilityEvent
import android.view.accessibility.AccessibilityNodeInfo
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.suspendCancellableCoroutine
import kotlinx.coroutines.withContext
import java.io.ByteArrayOutputStream
import kotlin.coroutines.resume

/**
 * Read-only accessibility service. It exposes the text of the focused window and
 * can take a single silent screenshot, but it never performs actions or gestures.
 */
class SprimeAccessibilityService : AccessibilityService() {
    companion object {
        private const val MAX_WIDTH = 720

        @Volatile
        private var current: SprimeAccessibilityService? = null

        val isConnected: Boolean
            get() = current != null

        /** The connected service, used by the AI agent to perform actions. */
        val instance: SprimeAccessibilityService?
            get() = current

        fun readScreen(limit: Int = 4000): String? = current?.capture(limit)

        val canCapture: Boolean
            get() = current != null && Build.VERSION.SDK_INT >= Build.VERSION_CODES.R

        /**
         * Takes one screenshot and returns it as a base64 JPEG. Rows below
         * [cropBottom] are dropped so the keyboard never covers the page.
         */
        suspend fun captureScreenshot(cropBottom: Int): String? {
            if (!canCapture) return null
            val service = current ?: return null
            val bitmap =
                suspendCancellableCoroutine<Bitmap?> { continuation ->
                    service.takeScreenshot(
                        Display.DEFAULT_DISPLAY,
                        service.mainExecutor,
                        object : TakeScreenshotCallback {
                            override fun onSuccess(result: ScreenshotResult) {
                                val hardware = result.hardwareBuffer
                                val full =
                                    Bitmap.wrapHardwareBuffer(hardware, result.colorSpace)
                                        ?.copy(Bitmap.Config.ARGB_8888, false)
                                hardware.close()
                                continuation.resume(full)
                            }

                            override fun onFailure(errorCode: Int) {
                                continuation.resume(null)
                            }
                        },
                    )
                } ?: return null
            return withContext(Dispatchers.Default) { encode(bitmap, cropBottom) }
        }

        /** A fully black frame means the capture was refused, for example by FLAG_SECURE. */
        private fun isBlank(bitmap: Bitmap): Boolean {
            var total = 0L
            var samples = 0
            val stepX = (bitmap.width / 8).coerceAtLeast(1)
            val stepY = (bitmap.height / 8).coerceAtLeast(1)
            var y = 0
            while (y < bitmap.height) {
                var x = 0
                while (x < bitmap.width) {
                    val pixel = bitmap.getPixel(x, y)
                    val r = (pixel shr 16) and 0xFF
                    val g = (pixel shr 8) and 0xFF
                    val b = pixel and 0xFF
                    total += (r + g + b) / 3
                    samples++
                    x += stepX
                }
                y += stepY
            }
            return samples == 0 || total / samples < 4
        }

        private fun encode(
            bitmap: Bitmap,
            cropBottom: Int,
        ): String? = runCatching {
            val height = if (cropBottom in 1 until bitmap.height) cropBottom else bitmap.height
            val cropped =
                if (height == bitmap.height) {
                    bitmap
                } else {
                    Bitmap.createBitmap(bitmap, 0, 0, bitmap.width, height).also { bitmap.recycle() }
                }
            val scale = MAX_WIDTH.toFloat() / cropped.width
            val scaled =
                if (scale < 1f) {
                    Bitmap.createScaledBitmap(
                        cropped,
                        MAX_WIDTH,
                        (cropped.height * scale).toInt().coerceAtLeast(1),
                        true,
                    ).also { cropped.recycle() }
                } else {
                    cropped
                }
            if (isBlank(scaled)) {
                scaled.recycle()
                return@runCatching null
            }
            val stream = ByteArrayOutputStream()
            scaled.compress(Bitmap.CompressFormat.JPEG, 70, stream)
            scaled.recycle()
            Base64.encodeToString(stream.toByteArray(), Base64.NO_WRAP)
        }.getOrNull()
    }

    override fun onServiceConnected() {
        runCatching { com.sprime.ime.overlay.QuickAnswerOverlay.attach(this) }
        current = this
    }

    override fun onAccessibilityEvent(event: AccessibilityEvent?) = Unit

    override fun onInterrupt() = Unit

    override fun onDestroy() {
        current = null
        runCatching { com.sprime.ime.overlay.QuickAnswerOverlay.release() }
        super.onDestroy()
    }

    private fun capture(limit: Int): String? {
        val fromWindows =
            windows.firstOrNull { it.isActive && it.root?.packageName != packageName }?.root
                ?: windows.firstOrNull { it.root?.packageName != packageName }?.root
        val root = fromWindows ?: rootInActiveWindow?.takeIf { it.packageName != packageName } ?: return null
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
            if (value.isNullOrBlank() || value.length < 2) continue
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
