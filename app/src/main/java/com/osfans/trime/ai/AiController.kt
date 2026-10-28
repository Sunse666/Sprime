/*
 * SPDX-FileCopyrightText: 2026 Sprime contributors
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

package com.osfans.trime.ai

import android.view.KeyEvent
import androidx.lifecycle.lifecycleScope
import com.osfans.trime.R
import com.osfans.trime.ai.model.AiDelta
import com.osfans.trime.ai.model.ChatMessage
import com.osfans.trime.ai.model.ChatRole
import com.osfans.trime.ai.provider.OpenAiCompatibleProvider
import com.osfans.trime.core.RimeKeyMapping
import com.osfans.trime.core.RimeMessage
import com.osfans.trime.ime.ai.AiPageWindow
import com.osfans.trime.ime.broadcast.InputBroadcastReceiver
import com.osfans.trime.ime.core.TrimeInputMethodService
import com.osfans.trime.ime.dependency.InputDependencyManager
import com.osfans.trime.ime.keyboard.KeyboardWindow
import com.osfans.trime.ime.window.BoardWindow
import com.osfans.trime.ime.window.BoardWindowManager
import kotlinx.coroutines.Job
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.launch
import org.kodein.di.instance

/**
 * Owns the AI panel state and the page switch between keyboard and AI page.
 * Both pages share the same fixed IME height, so switching never changes insets.
 */
class AiController : InputBroadcastReceiver {
    private val windowManager: BoardWindowManager by InputDependencyManager.getInstance().di.instance()
    private val service: TrimeInputMethodService by InputDependencyManager.getInstance().di.instance()

    private val settings = AiSettings()
    private val provider = OpenAiCompatibleProvider()

    private val _state = MutableStateFlow<AiPanelState>(AiPanelState.Idle)
    val state: StateFlow<AiPanelState> = _state.asStateFlow()

    private var requestJob: Job? = null

    var lastPrompt: String = ""
        private set

    var isOpen: Boolean = false
        private set

    var onStateChanged: ((Boolean) -> Unit)? = null

    private val _draft = MutableStateFlow("")
    val draft: StateFlow<String> = _draft.asStateFlow()

    var isComposing: Boolean = false
        private set

    var onComposeChanged: ((Boolean) -> Unit)? = null

    fun toggle() {
        if (isOpen) close() else open()
    }

    fun open() {
        if (isOpen) return
        windowManager.attachWindow(AiPageWindow())
    }

    fun close() {
        if (!isOpen) return
        windowManager.attachWindow(KeyboardWindow)
    }

    fun ask(prompt: String) {
        lastPrompt = prompt
        if (!settings.enabled) {
            _state.value = AiPanelState.Error(service.getString(R.string.ai_error_disabled))
            return
        }
        if (!settings.isConfigured) {
            _state.value = AiPanelState.Error(service.getString(R.string.ai_error_not_configured))
            return
        }
        requestJob?.cancel()
        _state.value = AiPanelState.Streaming("")
        requestJob =
            service.lifecycleScope.launch {
                val messages =
                    buildList {
                        if (settings.systemPrompt.isNotBlank()) {
                            add(ChatMessage(ChatRole.SYSTEM, settings.systemPrompt))
                        }
                        add(ChatMessage(ChatRole.USER, prompt))
                    }
                val text = StringBuilder()
                provider.chat(settings.requestConfig(), messages).collect { delta ->
                    when (delta) {
                        is AiDelta.Text -> {
                            text.append(delta.value)
                            _state.value = AiPanelState.Streaming(text.toString())
                        }

                        is AiDelta.Done -> _state.value = AiPanelState.Done(text.toString())

                        is AiDelta.Failure -> _state.value = AiPanelState.Error(delta.message)
                    }
                }
            }
    }

    fun startCompose() {
        if (isComposing) return
        isComposing = true
        onComposeChanged?.invoke(true)
    }

    fun stopCompose() {
        if (!isComposing) return
        isComposing = false
        onComposeChanged?.invoke(false)
    }

    fun appendText(text: String) {
        if (!isComposing) return
        _draft.value = _draft.value + text
    }

    fun deleteLast() {
        if (!isComposing) return
        val value = _draft.value
        if (value.isNotEmpty()) _draft.value = value.dropLast(1)
    }

    fun submitDraft() {
        if (!isComposing) return
        val prompt = _draft.value.trim()
        stopCompose()
        _draft.value = ""
        if (prompt.isEmpty()) return
        open()
        ask(prompt)
    }

    /**
     * Intercepts keys rime would forward to the editor while the draft is active.
     * Returns true when the key was consumed.
     */
    fun handleKey(data: RimeMessage.KeyMessage.Data): Boolean {
        if (!isComposing) return false
        val keyCode = data.value.keyCode
        val value = data.value.value
        return when {
            keyCode == KeyEvent.KEYCODE_DEL -> {
                deleteLast()
                true
            }

            value == RimeKeyMapping.RimeKey_Return || keyCode == KeyEvent.KEYCODE_ENTER -> {
                submitDraft()
                true
            }

            value in PRINTABLE_RANGE -> {
                appendText(String(Character.toChars(value)))
                true
            }

            else -> false
        }
    }

    fun stop() {
        requestJob?.cancel()
        requestJob = null
        _state.value = AiPanelState.Idle
    }

    fun retry() {
        if (lastPrompt.isNotBlank()) ask(lastPrompt)
    }

    fun reset() {
        stop()
    }

    override fun onWindowAttached(window: BoardWindow) {
        setOpen(window is AiPageWindow)
    }

    private companion object {
        val PRINTABLE_RANGE = 0x20..0x10FFFF
    }

    private fun setOpen(value: Boolean) {
        if (isOpen == value) return
        isOpen = value
        onStateChanged?.invoke(value)
    }
}
