/*
 * SPDX-FileCopyrightText: 2026 Sprime contributors
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

package com.osfans.trime.ui.main.settings

import androidx.preference.EditTextPreference
import androidx.preference.Preference
import androidx.preference.PreferenceScreen
import com.osfans.trime.R
import com.osfans.trime.ai.AiKeyStore
import com.osfans.trime.data.prefs.AppPrefs
import com.osfans.trime.data.prefs.PreferenceDelegateFragment

class AiSettingsFragment : PreferenceDelegateFragment(AppPrefs.defaultInstance().ai) {
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
    }
}
