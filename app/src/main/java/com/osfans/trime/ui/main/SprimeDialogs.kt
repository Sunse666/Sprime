/*
 * SPDX-FileCopyrightText: 2026 Sprime contributors
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

package com.osfans.trime.ui.main

import android.content.Context
import android.widget.ScrollView
import android.widget.TextView
import androidx.appcompat.app.AlertDialog
import com.osfans.trime.R

object SprimeDialogs {
    private const val PREFS = "sprime_ui"
    private const val KEY_INTRO_SHOWN = "intro_shown"

    fun showIntro(
        context: Context,
        markSeen: Boolean = true,
    ) {
        val text =
            TextView(context).apply {
                setText(R.string.sprime_intro_body)
                setPadding(48, 32, 48, 0)
                textSize = 15f
            }
        AlertDialog
            .Builder(context)
            .setTitle(R.string.sprime_intro_title)
            .setView(ScrollView(context).apply { addView(text) })
            .setPositiveButton(R.string.sprime_intro_ok, null)
            .show()
        if (markSeen) markIntroShown(context)
    }

    fun showPrivacy(context: Context) {
        val text =
            TextView(context).apply {
                setText(R.string.sprime_privacy_body)
                setPadding(48, 32, 48, 0)
                textSize = 15f
            }
        AlertDialog
            .Builder(context)
            .setTitle(R.string.sprime_privacy_title)
            .setView(ScrollView(context).apply { addView(text) })
            .setPositiveButton(android.R.string.ok, null)
            .show()
    }

    fun shouldShowIntro(context: Context): Boolean = !context.getSharedPreferences(PREFS, Context.MODE_PRIVATE).getBoolean(KEY_INTRO_SHOWN, false)

    private fun markIntroShown(context: Context) {
        context.getSharedPreferences(PREFS, Context.MODE_PRIVATE).edit().putBoolean(KEY_INTRO_SHOWN, true).apply()
    }
}
