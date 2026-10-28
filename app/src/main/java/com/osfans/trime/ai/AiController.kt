/*
 * SPDX-FileCopyrightText: 2026 Sprime contributors
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

package com.osfans.trime.ai

import android.view.KeyEvent
import androidx.lifecycle.lifecycleScope
import com.osfans.trime.R
import com.osfans.trime.ai.chat.ChatSession
import com.osfans.trime.ai.model.AiDelta
import com.osfans.trime.ai.privacy.PiiFilter
import com.osfans.trime.ai.prompt.AiAction
import com.osfans.trime.ai.prompt.PromptBuilder
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
    companion object {
        private val PRINTABLE_RANGE = 0x20..0x10FFFF
        private const val NEWLINE = '\n'
    }

    data class Draft(
        val text: String = "",
        val cursor: Int = 0,
    )

    private val windowManager: BoardWindowManager by InputDependencyManager.getInstance().di.instance()
    private val service: TrimeInputMethodService by InputDependencyManager.getInstance().di.instance()

    private val settings = AiSettings()
    private val provider = OpenAiCompatibleProvider()

    private val session =
        ChatSession { PromptBuilder.systemMessage(settings.systemPrompt) }

    private val _state = MutableStateFlow<AiPanelState>(AiPanelState.Idle)
    val state: StateFlow<AiPanelState> = _state.asStateFlow()

    private val _draft = MutableStateFlow(Draft())
    val draft: StateFlow<Draft> = _draft.asStateFlow()

    private var requestJob: Job? = null

    var lastPrompt: String = ""
        private set

    var hasSelection: Boolean = false
        private set

    var isComposing: Boolean = false
        private set

    var isOpen: Boolean = false
        private set

    var onStateChanged: ((Boolean) -> Unit)? = null

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

    fun startCompose() {
        if (isComposing) return
        isComposing = true
        _draft.value = Draft()
        onComposeChanged?.invoke(true)
    }

    fun stopCompose() {
        if (!isComposing) return
        isComposing = false
        onComposeChanged?.invoke(false)
    }

    fun setCursor(position: Int) {
        if (!isComposing) return
        val current = _draft.value
        val clamped = position.coerceIn(0, current.text.length)
        if (clamped == current.cursor) return
        _draft.value = current.copy(cursor = clamped)
    }

    fun appendText(text: String) {
        if (!isComposing || text.isEmpty()) return
        val current = _draft.value
        val insertAt = current.cursor.coerceIn(0, current.text.length)
        val updated =
            current.text.substring(0, insertAt) + text + current.text.substring(insertAt)
        _draft.value = Draft(updated, insertAt + text.length)
    }

    fun deleteBackward() {
        if (!isComposing) return
        val current = _draft.value
        if (current.cursor == 0) return
        val from = (current.cursor - 1).coerceAtLeast(0)
        val updated = current.text.removeRange(from, current.cursor)
        _draft.value = Draft(updated, from)
    }

    fun submitDraft() {
        if (!isComposing) return
        val question = _draft.value.text.trim()
        stopCompose()
        _draft.value = Draft()
        if (question.isEmpty()) return
        open()
        ask(PromptBuilder.buildCustom(question, service.captureEditorContext(settings.useClipboard)))
    }

    fun startInputFromPanel() {
        close()
        startCompose()
    }

    /** Runs a quick action on the current selection (or the text before the cursor). */
    fun runAction(action: AiAction) {
        val context = service.captureEditorContext(settings.useClipboard)
        open()
        when {
            context.isPassword -> {
                _state.value = AiPanelState.Error(service.getString(R.string.ai_error_password))
            }

            !context.hasContent -> {
                _state.value = AiPanelState.Error(service.getString(R.string.ai_error_no_text))
            }

            else -> {
                session.reset()
                ask(PromptBuilder.build(action, context))
            }
        }
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
                deleteBackward()
                true
            }

            value == RimeKeyMapping.RimeKey_Return || keyCode == KeyEvent.KEYCODE_ENTER -> {
                appendText(NEWLINE.toString())
                true
            }

            value in PRINTABLE_RANGE -> {
                appendText(String(Character.toChars(value)))
                true
            }

            else -> false
        }
    }

    fun ask(prompt: String) {
        lastPrompt = prompt
        hasSelection = service.currentInputConnection?.getSelectedText(0).isNullOrEmpty().not()
        if (!settings.enabled) {
            _state.value = AiPanelState.Error(service.getString(R.string.ai_error_disabled))
            return
        }
        if (!settings.isConfigured) {
            _state.value = AiPanelState.Error(service.getString(R.string.ai_error_not_configured))
            return
        }
        session.addUser(PiiFilter.sanitize(prompt, settings.piiOptions).trim())
        startRequest()
    }

    private fun startRequest() {
        requestJob?.cancel()
        _state.value = AiPanelState.Streaming("")
        val messages = session.messages()
        requestJob =
            service.lifecycleScope.launch {
                val text = StringBuilder()
                val thinking = StringBuilder()
                provider.chat(settings.requestConfig(), messages).collect { delta ->
                    when (delta) {
                        is AiDelta.Text -> {
                            text.append(delta.value)
                            _state.value = AiPanelState.Streaming(text.toString(), thinking.toString())
                        }

                        is AiDelta.Reasoning -> {
                            thinking.append(delta.value)
                            _state.value = AiPanelState.Streaming(text.toString(), thinking.toString())
                        }

                        is AiDelta.Done -> {
                            session.addAssistant(text.toString())
                            if (settings.autoInsert) {
                                service.commitTextToEditor(text.toString())
                                _state.value = AiPanelState.Inserted(text.toString())
                            } else {
                                _state.value = AiPanelState.Done(text.toString(), thinking.toString())
                            }
                        }

                        is AiDelta.Failure -> _state.value = AiPanelState.Error(delta.message)
                    }
                }
            }
    }

    fun stop() {
        requestJob?.cancel()
        requestJob = null
        _state.value = AiPanelState.Idle
    }

    fun retry() {
        if (session.hasUserTurn) startRequest()
    }

    fun newConversation() {
        requestJob?.cancel()
        requestJob = null
        session.reset()
        _state.value = AiPanelState.Idle
    }

    fun currentAnswer(): String? = (state.value as? AiPanelState.Done)?.text?.takeIf { it.isNotBlank() }

    fun insertAnswer() {
        val answer = currentAnswer() ?: return
        service.commitTextToEditor(answer)
        _state.value = AiPanelState.Inserted(answer)
    }

    fun copyAnswer() {
        currentAnswer()?.let { service.copyToClipboard(it) }
    }

    fun undoLastCommit() {
        service.undoLastCommit()
        _state.value = AiPanelState.Idle
    }

    override fun onWindowAttached(window: BoardWindow) {
        setOpen(window is AiPageWindow)
    }

    private fun setOpen(value: Boolean) {
        if (isOpen == value) return
        isOpen = value
        onStateChanged?.invoke(value)
    }
}
