/*
 * SPDX-FileCopyrightText: 2026 Sprime contributors
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

package com.osfans.trime.ui.main.settings

import android.content.Intent
import android.provider.Settings
import androidx.preference.EditTextPreference
import androidx.preference.Preference
import androidx.preference.PreferenceScreen
import com.osfans.trime.R
import com.osfans.trime.ai.AiKeyStore
import com.osfans.trime.data.prefs.AppPrefs
import com.osfans.trime.data.prefs.PreferenceDelegateFragment
import com.sprime.ime.access.SprimeAccessibilityService

class AiSettingsFragment : PreferenceDelegateFragment(AppPrefs.defaultInstance().ai) {
    private var accessPreference: Preference? = null

    override fun onPreferenceUiCreated(screen: PreferenceScreen) {
        val context = requireContext()
        val keyPreference =
            EditTextPreference(context).apply {
                key = "ai_api_key"
                order = 0
                isPersistent = false
                title = context.getString(R.string.ai_api_key)
                dialogMessage = context.getString(R.string.ai_api_key_hint)
                summaryProvider =
                    Preference.SummaryProvider<EditTextPreference> {
                        context.getString(
                            if (AiKeyStore.get().isBlank()) R.string.ai_key_unset else R.string.ai_key_set,
                        )
                    }
                setOnPreferenceChangeListener { _, newValue ->
                    AiKeyStore.set(newValue?.toString()?.trim().orEmpty())
                    true
                }
            }
        screen.addPreference(keyPreference)

        val access =
            Preference(context).apply {
                key = "ai_accessibility"
                order = 1
                title = context.getString(R.string.ai_accessibility_title)
                setOnPreferenceClickListener {
                    runCatching {
                        context.startActivity(Intent(Settings.ACTION_ACCESSIBILITY_SETTINGS))
                    }
                    true
                }
            }
        accessPreference = access
        screen.addPreference(access)
        refreshAccessSummary()

        val legend =
            Preference(context).apply {
                key = "ai_strip_legend"
                isPersistent = false
                title = context.getString(R.string.ai_strip_legend_title)
                summary = context.getString(R.string.ai_strip_legend_summary)
            }
        screen.addPreference(legend)

        val strip =
            Preference(context).apply {
                key = "ai_strip_settings"
                isPersistent = false
                title = "侧边条"
                summary = "按钮、指示灯、指令与规则"
                setOnPreferenceClickListener {
                    context.startActivity(android.content.Intent(context, com.sprime.ime.strip.StripSettingsActivity::class.java))
                    true
                }
            }
        screen.addPreference(strip)
    }

    override fun onResume() {
        super.onResume()
        refreshAccessSummary()
    }

    private fun refreshAccessSummary() {
        accessPreference?.summary =
            requireContext().getString(
                if (SprimeAccessibilityService.isConnected) R.string.ai_accessibility_on else R.string.ai_accessibility_off,
            )
    }
}
