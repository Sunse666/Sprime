/*
 * SPDX-FileCopyrightText: 2026 Sprime contributors
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

package com.osfans.trime.ai

import com.osfans.trime.ai.privacy.PiiFilter
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
        get() = prefs.systemPrompt.getValue()

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

    fun requestConfig(): AiRequestConfig = AiRequestConfig(
        baseUrl = baseUrl,
        apiKey = apiKey,
        model = model,
        temperature = prefs.temperature.getValue() / 100.0,
        maxTokens = prefs.maxTokens.getValue(),
        stream = prefs.stream.getValue(),
    )
}
