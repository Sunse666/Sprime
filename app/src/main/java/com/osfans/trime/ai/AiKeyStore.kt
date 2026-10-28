/*
 * SPDX-FileCopyrightText: 2026 Sprime contributors
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

package com.osfans.trime.ai

import android.content.Context
import android.content.SharedPreferences
import android.os.Build
import androidx.core.content.edit
import androidx.security.crypto.EncryptedSharedPreferences
import androidx.security.crypto.MasterKey
import com.osfans.trime.util.appContext

/**
 * API keys live outside the normal preference file and are encrypted at rest
 * whenever the platform supports keystore-backed encryption (API 23+).
 */
object AiKeyStore {
    private const val FILE = "sprime_ai_secret"
    private const val KEY = "api_key"

    private var cached: SharedPreferences? = null

    private fun prefs(): SharedPreferences {
        cached?.let { return it }
        synchronized(this) {
            cached?.let { return it }
            val created = create()
            cached = created
            return created
        }
    }

    private fun create(): SharedPreferences {
        val context = appContext
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            runCatching {
                val masterKey =
                    MasterKey.Builder(context)
                        .setKeyScheme(MasterKey.KeyScheme.AES256_GCM)
                        .build()
                return EncryptedSharedPreferences.create(
                    context,
                    FILE,
                    masterKey,
                    EncryptedSharedPreferences.PrefKeyEncryptionScheme.AES256_SIV,
                    EncryptedSharedPreferences.PrefValueEncryptionScheme.AES256_GCM,
                )
            }
        }
        return context.getSharedPreferences(FILE, Context.MODE_PRIVATE)
    }

    fun get(): String = prefs().getString(KEY, "").orEmpty()

    fun set(value: String) {
        prefs().edit { putString(KEY, value) }
    }
}
