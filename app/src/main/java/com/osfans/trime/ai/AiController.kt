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
import com.osfans.trime.ai.prompt.InsertParser
import com.osfans.trime.ai.prompt.PromptBuilder
import com.osfans.trime.ai.prompt.ScreenHints
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
import com.sprime.ime.access.SprimeAccessibilityService
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
        private const val SCREEN_SENTINEL = "[screenshot]"
        private val SCREEN_HINTS =
            listOf("截图", "截屏", "看屏幕", "看下屏幕", "看看屏幕", "屏幕内容", "screenshot", "screen")
        private const val SCREEN_LOOK_PROMPT =
            "这是当前屏幕的截图，请结合它回答刚才的问题。"
        private const val SCREEN_LOOK_FAILED =
            "截图失败了，请只用已有信息回答。"
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

    private val _transcript = MutableStateFlow("")
    val transcript: StateFlow<String> = _transcript.asStateFlow()

    private val _screenText = MutableStateFlow<String?>(null)
    val screenText: StateFlow<String?> = _screenText.asStateFlow()

    private var lastInsertText: String? = null
    private var askedFromAction = false

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
        askedFromAction = false
        val context = service.captureEditorContext(settings.useClipboard)
        ask(PromptBuilder.buildCustom(question, context, _screenText.value.orEmpty()))
    }

    fun startInputFromPanel() {
        close()
        startCompose()
    }

    /** Runs a quick action on the current selection (or the text before the cursor). */
    fun runAction(action: AiAction) {
        val context = service.captureEditorContext(settings.useClipboard)
        open()
        val screen = _screenText.value
        when {
            context.isPassword -> {
                _state.value = AiPanelState.Error(service.getString(R.string.ai_error_password))
            }

            screen.isNullOrBlank() && !context.hasContent -> {
                _state.value = AiPanelState.Error(service.getString(R.string.ai_error_no_text))
            }

            else -> {
                session.reset()
                askedFromAction = true
                ask(PromptBuilder.build(action, screen ?: context.content.orEmpty()))
            }
        }
    }

    /** Reads the current screen once and keeps it as the context of the next questions. */
    fun captureScreen() {
        open()
        if (!SprimeAccessibilityService.isConnected) {
            _state.value = AiPanelState.Error(service.getString(R.string.ai_error_no_accessibility))
            return
        }
        val text = SprimeAccessibilityService.readScreen()
        if (text.isNullOrBlank()) {
            _state.value = AiPanelState.Error(service.getString(R.string.ai_error_screen_empty))
            return
        }
        _screenText.value = text
        _state.value = AiPanelState.Idle
    }

    fun clearScreen() {
        _screenText.value = null
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
        lastInsertText = null
        hasSelection = service.currentInputConnection?.getSelectedText(0).isNullOrEmpty().not()
        if (!settings.enabled) {
            _state.value = AiPanelState.Error(service.getString(R.string.ai_error_disabled))
            return
        }
        if (!settings.isConfigured) {
            _state.value = AiPanelState.Error(service.getString(R.string.ai_error_not_configured))
            return
        }
        val safe = PiiFilter.sanitize(prompt, settings.piiOptions).trim()
        session.addUser(safe)
        if (settings.allowScreenshot && ScreenHints.matches(safe) && SprimeAccessibilityService.canCapture) {
            requestJob?.cancel()
            _state.value = AiPanelState.Streaming("")
            requestJob =
                service.lifecycleScope.launch {
                    val image =
                        captureWithSecureFlagOff()
                    if (image != null) session.addUser(SCREEN_LOOK_PROMPT, image)
                    runConversation()
                }
            return
        }
        startRequest()
    }

    /** True when the question explicitly asks for a screenshot of the current screen. */
    private fun wantsScreen(text: String): Boolean = SCREEN_HINTS.any { text.contains(it, ignoreCase = true) }

    private fun startRequest() {
        requestJob?.cancel()
        _state.value = AiPanelState.Streaming("")
        requestJob = service.lifecycleScope.launch { runConversation() }
    }

    /**
     * FLAG_SECURE on the full screen IME window blanks the whole screenshot, so it
     * is dropped for the moment the frame is captured and restored right after.
     */
    private suspend fun captureWithSecureFlagOff(): String? {
        service.setSecureForCapture(false)
        return try {
            kotlinx.coroutines.delay(80)
            SprimeAccessibilityService.captureScreenshot(service.imeTopOnScreen())
        } finally {
            service.setSecureForCapture(true)
        }
    }

    private suspend fun runConversation() {
        var rounds = 0
        while (true) {
            val text = StringBuilder()
            val thinking = StringBuilder()
            var failed = false
            provider.chat(settings.requestConfig(), session.messages()).collect { delta ->
                when (delta) {
                    is AiDelta.Text -> {
                        text.append(delta.value)
                        _state.value = AiPanelState.Streaming(text.toString(), thinking.toString())
                    }

                    is AiDelta.Reasoning -> {
                        thinking.append(delta.value)
                        _state.value = AiPanelState.Streaming(text.toString(), thinking.toString())
                    }

                    is AiDelta.Failure -> {
                        _state.value = AiPanelState.Error(delta.message)
                        failed = true
                    }

                    is AiDelta.Done -> Unit
                }
            }
            if (failed) return
            val raw = text.toString()
            if (rounds == 0 && settings.allowScreenshot && raw.contains(SCREEN_SENTINEL)) {
                _state.value = AiPanelState.Streaming("", "")
                val image =
                    captureWithSecureFlagOff()
                rounds++
                if (image != null) {
                    session.addUser(SCREEN_LOOK_PROMPT, image)
                    continue
                }
                session.addUser(SCREEN_LOOK_FAILED)
                continue
            }
            finishAnswer(raw.replace(SCREEN_SENTINEL, "").trim(), thinking.toString())
            return
        }
    }

    private fun finishAnswer(
        raw: String,
        thinking: String,
    ) {
        val parsed = InsertParser.parse(raw)
        val insert = parsed.insert ?: if (askedFromAction) parsed.display else null
        lastInsertText = insert
        session.addAssistant(parsed.display)
        _transcript.value = buildTranscript()
        if (settings.autoInsert && !insert.isNullOrBlank()) {
            service.commitTextToEditor(insert)
            _state.value = AiPanelState.Inserted(parsed.display.ifBlank { insert })
        } else {
            _state.value = AiPanelState.Done(parsed.display, thinking, insert)
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
        _transcript.value = ""
        _screenText.value = null
        _state.value = AiPanelState.Idle
    }

    private fun buildTranscript(): String = session.history().joinToString("\n\n") { message ->
        val prefix =
            if (message.role == com.osfans.trime.ai.model.ChatRole.USER) "你：" else "AI："
        prefix + message.content.trim()
    }

    fun currentAnswer(): String? = (state.value as? AiPanelState.Done)?.text?.takeIf { it.isNotBlank() }

    fun insertAnswer() {
        val answer = (state.value as? AiPanelState.Done)?.insertText ?: currentAnswer() ?: return
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
