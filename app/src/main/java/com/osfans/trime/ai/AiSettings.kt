/*
 * SPDX-FileCopyrightText: 2026 Sprime contributors
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

package com.osfans.trime.ai

import com.osfans.trime.ai.privacy.PiiFilter
import com.osfans.trime.ai.agent.AiTool
import com.osfans.trime.ai.agent.ApprovalPolicy
import com.osfans.trime.ai.agent.PermissionLevel
import com.osfans.trime.ai.prompt.AiAction
import com.osfans.trime.ai.prompt.DefaultPrompts
import com.osfans.trime.ai.provider.AiRequestConfig
import com.osfans.trime.ai.provider.ProviderPresets
import com.osfans.trime.data.prefs.AppPrefs

class AiSettings {
    private val prefs = AppPrefs.defaultInstance().ai

    private val preset get() = ProviderPresets.find(prefs.provider.getValue())

    val enabled: Boolean
        get() = prefs.enabled.getValue()

    val apiKey: String
        get() = AiKeyStore.get()

    val baseUrl: String
        get() = prefs.baseUrl.getValue().ifBlank { preset.baseUrl }

    val model: String
        get() = prefs.model.getValue().ifBlank { preset.model }

    val systemPrompt: String
        get() = prefs.systemPrompt.getValue().ifBlank { DefaultPrompts.SYSTEM }

    fun actionInstruction(action: AiAction): String {
        val raw = when (action) {
            AiAction.TRANSLATE -> prefs.promptTranslate.getValue()
            AiAction.POLISH -> prefs.promptPolish.getValue()
            AiAction.SUMMARIZE -> prefs.promptSummarize.getValue()
            AiAction.EXPLAIN -> prefs.promptExplain.getValue()
            AiAction.REPLY -> prefs.promptReply.getValue()
            AiAction.CONTINUE -> prefs.promptContinue.getValue()
        }
        return raw.ifBlank { action.defaultInstruction }
    }

    val screenLookPrompt: String
        get() = prefs.promptScreenLook.getValue().ifBlank { DefaultPrompts.SCREEN_LOOK }

    val screenFailedPrompt: String
        get() = prefs.promptScreenFailed.getValue().ifBlank { DefaultPrompts.SCREEN_FAILED }

    val useClipboard: Boolean
        get() = prefs.useClipboard.getValue()

    val autoInsert: Boolean
        get() = prefs.autoInsert.getValue()

    val allowScreenshot: Boolean
        get() = prefs.allowScreenshot.getValue()

    val agentEnabled: Boolean
        get() = prefs.agentEnabled.getValue()

    /** 0 means no step limit. */
    val agentMaxSteps: Int
        get() = prefs.agentMaxSteps.getValue()

    val approvalPolicy: ApprovalPolicy
        get() = ApprovalPolicy.parse(prefs.approvalPolicy.getValue()) ?: ApprovalPolicy.DANGEROUS_ONLY

    private fun permissionValue(tool: String): String =
        when (tool) {
            "read_screen" -> prefs.permReadScreen.getValue()
            "describe_screen" -> prefs.permDescribeScreen.getValue()
            "take_screenshot" -> prefs.permScreenshot.getValue()
            "click" -> prefs.permClick.getValue()
            "scroll" -> prefs.permScroll.getValue()
            "type_text" -> prefs.permTypeText.getValue()
            "gesture" -> prefs.permGesture.getValue()
            else -> ""
        }

    fun permissionFor(tool: AiTool): PermissionLevel {
        PermissionLevel.parse(permissionValue(tool.name))?.let { return it }
        return when (approvalPolicy) {
            ApprovalPolicy.AUTO -> PermissionLevel.ALLOW
            ApprovalPolicy.EVERY_STEP -> PermissionLevel.ASK
            ApprovalPolicy.DANGEROUS_ONLY -> if (tool.dangerous) PermissionLevel.ASK else PermissionLevel.ALLOW
        }
    }

    fun rememberAllow(tool: String) {
        when (tool) {
            "read_screen" -> prefs.permReadScreen.setValue("ALLOW")
            "describe_screen" -> prefs.permDescribeScreen.setValue("ALLOW")
            "take_screenshot" -> prefs.permScreenshot.setValue("ALLOW")
            "click" -> prefs.permClick.setValue("ALLOW")
            "scroll" -> prefs.permScroll.setValue("ALLOW")
            "type_text" -> prefs.permTypeText.setValue("ALLOW")
            "gesture" -> prefs.permGesture.setValue("ALLOW")
        }
    }

    val piiOptions: PiiFilter.Options
        get() =
            PiiFilter.Options(
                phone = prefs.piiPhone.getValue(),
                idCard = prefs.piiIdCard.getValue(),
                bankCard = prefs.piiBankCard.getValue(),
                email = prefs.piiEmail.getValue(),
            )

    val isConfigured: Boolean
        get() = apiKey.isNotBlank() || baseUrl.startsWith("http://127.0.0.1")

    /** Store the built-in text for every blank prompt so the settings always show it. */
    fun fillEmptyPrompts() {
        fun ensure(delegate: com.osfans.trime.data.prefs.PreferenceDelegate<String>, default: String) {
            if (delegate.getValue().isBlank()) delegate.setValue(default)
        }
        ensure(prefs.systemPrompt, DefaultPrompts.SYSTEM)
        ensure(prefs.promptTranslate, DefaultPrompts.TRANSLATE)
        ensure(prefs.promptPolish, DefaultPrompts.POLISH)
        ensure(prefs.promptSummarize, DefaultPrompts.SUMMARIZE)
        ensure(prefs.promptExplain, DefaultPrompts.EXPLAIN)
        ensure(prefs.promptReply, DefaultPrompts.REPLY)
        ensure(prefs.promptContinue, DefaultPrompts.CONTINUE)
        ensure(prefs.promptScreenLook, DefaultPrompts.SCREEN_LOOK)
        ensure(prefs.promptScreenFailed, DefaultPrompts.SCREEN_FAILED)
    }

    fun requestConfig(): AiRequestConfig = AiRequestConfig(
        baseUrl = baseUrl,
        apiKey = apiKey,
        model = model,
        temperature = prefs.temperature.getValue() / 100.0,
        maxTokens = prefs.maxTokens.getValue(),
        stream = prefs.stream.getValue(),
    )
}
