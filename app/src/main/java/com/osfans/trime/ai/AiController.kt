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
        private const val MAX_SCREEN_ROUNDS = 3
        private const val APPROVAL_HIDE_DELAY = 300L
        private const val TOOL_TIMEOUT_MS = 15_000L
        private val SCREEN_HINTS =
            listOf("截图", "截屏", "看屏幕", "看下屏幕", "看看屏幕", "屏幕内容", "screenshot", "screen")
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

    private val _approval = MutableStateFlow<com.osfans.trime.ai.agent.ApprovalRequest?>(null)
    val approval: StateFlow<com.osfans.trime.ai.agent.ApprovalRequest?> = _approval.asStateFlow()
    private var approvalDeferred: kotlinx.coroutines.CompletableDeferred<Boolean>? = null
    private var approveAllForRun = false
    private var lastSignature: String? = null
    private var repeatCount = 0

    private val toolRegistry =
        com.osfans.trime.ai.agent.ToolRegistry {
            captureWithSecureFlagOff()
        }

    /** Answers reused while the conversation stays open; cleared on a new one. */
    private val answerCache = mutableMapOf<String, AiPanelState.Done>()

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
                ask(PromptBuilder.build(settings.actionInstruction(action), screen ?: context.content.orEmpty()))
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
        approveAllForRun = false
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
        answerCache[safe]?.let { cached ->
            _state.value = cached
            lastInsertText = cached.insertText
            return
        }
        session.addUser(safe)
        if (settings.allowScreenshot && ScreenHints.matches(safe) && SprimeAccessibilityService.canCapture) {
            requestJob?.cancel()
            _state.value = AiPanelState.Streaming("")
            requestJob =
                service.lifecycleScope.launch {
                    val image =
                        captureWithSecureFlagOff()
                    if (image != null) session.addUser(settings.screenLookPrompt, image)
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

    /** One user turn: loops until the model stops asking for tools. */
    private suspend fun runConversation() {
        var step = 0
        var pendingText = StringBuilder()
        val stepLog = StringBuilder()
        while (true) {
            if (settings.agentMaxSteps in 1..step) {
                finishAnswer(stepLog.toString() + "\n\n已达单轮步数上限（" + settings.agentMaxSteps + "）", "")
                return
            }
            val text = StringBuilder()
            val thinking = StringBuilder()
            var failed = false
            var toolCallsJson: String? = null
            val tools = if (settings.agentEnabled) toolRegistry.specs() else emptyList()
            provider.chat(settings.requestConfig(), session.messages(), tools).collect { delta ->
                when (delta) {
                    is AiDelta.Text -> {
                        text.append(delta.value)
                        _state.value = AiPanelState.Streaming((pendingText.toString() + text.toString()).trim(), thinking.toString())
                    }

                    is AiDelta.Reasoning -> {
                        thinking.append(delta.value)
                        _state.value = AiPanelState.Streaming((pendingText.toString() + text.toString()).trim(), thinking.toString())
                    }

                    is AiDelta.ToolCalls -> toolCallsJson = delta.json

                    is AiDelta.Failure -> {
                        _state.value = AiPanelState.Error(delta.message)
                        failed = true
                    }

                    is AiDelta.Done -> Unit
                }
            }
            if (failed) return
            val answer = text.toString()
            val calls = parseToolCalls(toolCallsJson)
            if (calls.isEmpty()) {
                val merged = (pendingText.toString() + answer).trim()
                if (stepLog.isNotEmpty()) stepLog.append("\n")
                finishAnswer(merged, thinking.toString())
                return
            }
            session.addAssistant(answer.trim(), calls.first().rawJson)
            step++
            calls.forEach { call ->
                call.result.toMessage(call.id, call.name).forEach { session.addMessage(it) }
                pendingText.append("· ").append(stepLine(call.name, call.result)).append("\n")
            }
            _state.value = AiPanelState.Streaming(pendingText.toString().trim(), thinking.toString())
        }
    }


    private suspend fun awaitApproval(tool: String): Boolean {
        val deferred = kotlinx.coroutines.CompletableDeferred<Boolean>()
        approvalDeferred = deferred
        _approval.value = com.osfans.trime.ai.agent.ApprovalRequest(tool, tool)
        return try {
            deferred.await()
        } finally {
            _approval.value = null
            approvalDeferred = null
        }
    }

    private suspend fun runToolWithKeyboardHidden(call: com.osfans.trime.ai.agent.ToolCall): com.osfans.trime.ai.agent.ToolResult {
        // The IME window covers the page, so it has to go away before touching other apps.
        service.requestHideSelf(0)
        kotlinx.coroutines.delay(APPROVAL_HIDE_DELAY)
        val result =
            kotlinx.coroutines.withTimeoutOrNull(TOOL_TIMEOUT_MS) { toolRegistry.execute(call) }
                ?: com.osfans.trime.ai.agent.ToolResult("工具执行超时")
        // Bring the panel back so the user can follow the steps.
        runCatching { service.requestShowSelf(0) }
        if (repeatCount >= 2) {
            return com.osfans.trime.ai.agent.ToolResult(
                result.text + "\n[系统提示] 同一个工具用相同参数连续调用 " + repeatCount + " 次，" +
                    "请停止重复，换一种做法或直接向用户说明卡点。",
            )
        }
        return result
    }

    private data class ParsedCall(
        val id: String,
        val name: String,
        val result: com.osfans.trime.ai.agent.ToolResult,
        val rawJson: String?,
    )

    private suspend fun parseToolCalls(raw: String?): List<ParsedCall> {
        if (raw.isNullOrBlank()) return emptyList()
        val array = runCatching { org.json.JSONArray(raw) }.getOrNull() ?: return emptyList()
        val parsed = mutableListOf<ParsedCall>()
        for (i in 0 until array.length()) {
            val item = array.optJSONObject(i) ?: continue
            val function = item.optJSONObject("function") ?: continue
            val call =
                com.osfans.trime.ai.agent.ToolCall(
                    id = item.optString("id", "call_" + i),
                    name = function.optString("name"),
                    arguments = function.optString("arguments", "{}"),
                )
            val signature = call.name + "|" + call.arguments
            repeatCount = if (signature == lastSignature) repeatCount + 1 else 1
            lastSignature = signature

            val tool = toolRegistry.find(call.name)
            var result: com.osfans.trime.ai.agent.ToolResult
            if (tool == null) {
                result = com.osfans.trime.ai.agent.ToolResult("没有名为 " + call.name + " 的工具")
            } else {
                val level = settings.permissionFor(tool)
                if (level == com.osfans.trime.ai.agent.PermissionLevel.FORBID) {
                    result = com.osfans.trime.ai.agent.ToolResult("用户禁止了这个操作")
                } else if (level == com.osfans.trime.ai.agent.PermissionLevel.ASK && !approveAllForRun) {
                    val approved = awaitApproval(call.name)
                    if (!approved) {
                        result = com.osfans.trime.ai.agent.ToolResult("用户拒绝了这次操作")
                    } else {
                        result = runToolWithKeyboardHidden(call)
                    }
                } else {
                    result = runToolWithKeyboardHidden(call)
                }
            }
            parsed += ParsedCall(call.id, call.name, result, raw)
        }
        return parsed
    }

    private fun stepLine(name: String, result: com.osfans.trime.ai.agent.ToolResult): String =
        name + "：" + result.text.lineSequence().firstOrNull().orEmpty().take(80)

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
        (_state.value as? AiPanelState.Done)?.let { answerCache[lastPrompt] = it }
    }

    fun stop() {
        requestJob?.cancel()
        requestJob = null
        _state.value = AiPanelState.Idle
    }

    fun retry() {
        if (session.hasUserTurn) startRequest()
    }


    /** Called from the panel when the user answers an approval request. */
    /** Marks every remaining step of this turn as approved. */
    fun allowAllForRun() {
        approveAllForRun = true
        resolveApproval(allow = true)
    }

    fun resolveApproval(
        allow: Boolean,
        remember: Boolean = false,
    ) {
        val request = _approval.value
        if (allow && remember && request != null) {
            settings.rememberAllow(request.tool)
        }
        _approval.value = null
        approvalDeferred?.complete(allow)
        approvalDeferred = null
    }

    fun newConversation() {
        requestJob?.cancel()
        requestJob = null
        session.reset()
        answerCache.clear()
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
