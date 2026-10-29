/*
 * SPDX-FileCopyrightText: 2015 - 2026 Rime community
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

package com.osfans.trime.data.theme

import android.content.res.Configuration
import com.osfans.trime.core.Rime
import com.osfans.trime.data.base.DataManager
import com.osfans.trime.data.prefs.AppPrefs
import com.osfans.trime.ime.symbol.LiquidData
import com.osfans.trime.util.WeakHashSet
import com.osfans.trime.util.appContext
import com.osfans.trime.util.yaml.Yaml
import com.osfans.trime.util.yaml.mapping
import timber.log.Timber
import java.io.File

object ThemeManager {
    private const val LEGACY_XIGE_THEME_ID = "sigma_IBM"
    private const val XIGE_THEME_ID = "sprime_xige"

    fun interface OnThemeChangeListener {
        fun onThemeChange(theme: Theme)
    }

    fun getAllThemes(): List<ThemeItem> {
        val sharedThemes = ThemeFilesManager.listThemes(DataManager.sharedDataDir)
        val userThemes = ThemeFilesManager.listThemes(DataManager.userDataDir)
        return sharedThemes + userThemes
    }

    private lateinit var _activeTheme: Theme

    private fun ensureActiveTheme() {
        if (!::_activeTheme.isInitialized) {
            _activeTheme = evaluateActiveTheme()
        }
    }

    var activeTheme: Theme
        get() {
            ensureActiveTheme()
            return _activeTheme
        }
        private set(value) {
            if (::_activeTheme.isInitialized && _activeTheme == value) return
            _activeTheme = value
            fireChange()
        }

    private val onChangeListeners = WeakHashSet<OnThemeChangeListener>()

    fun addOnChangedListener(listener: OnThemeChangeListener) {
        onChangeListeners.add(listener)
    }

    fun removeOnChangedListener(listener: OnThemeChangeListener) {
        onChangeListeners.remove(listener)
    }

    private fun fireChange() {
        onChangeListeners.forEach { it.onThemeChange(_activeTheme) }
    }

    val prefs = AppPrefs.defaultInstance().registerProvider(::ThemePrefs)

    private data class ResolvedTheme(
        val configId: String,
        val theme: Theme,
    )

    private fun loadThemeByIdOrNull(id: String): Theme? {
        // Themes bundled with the app are read from the synced shared directory so that a
        // stale copy in the user directory (or an external sync folder) cannot override them.
        val bundled = File(DataManager.sharedDataDir, "$id.trime.yaml")
        if (bundled.exists()) {
            return runCatching {
                Yaml.parseToYamlNode(bundled.readText()).mapping?.let { Theme.decode(it) }
            }.onFailure { Timber.w(it, "Failed to load bundled theme '$id'") }.getOrNull()
        }
        if (!Rime.deployRimeConfigFile(id, "config_version")) {
            Timber.w("Failed to deploy theme config file '$id.yaml'")
        }
        val file = File(DataManager.resolveDeployedResourcePath(id))
        if (!file.exists()) {
            Timber.w("Theme file not found for '$id'")
            return null
        }
        return try {
            val node = Yaml.parseToYamlNode(file.readText())
            val mapping = node.mapping
            if (mapping == null) {
                Timber.w("Failed to load theme '$id': YAML root is not a mapping")
                null
            } else {
                Theme.decode(mapping)
            }
        } catch (e: Exception) {
            Timber.w(e, "Failed to load theme '$id'")
            null
        }
    }

    private fun getThemeById(id: String): ResolvedTheme {
        loadThemeByIdOrNull(id)?.let { return ResolvedTheme(id, it) }

        if (id != "trime") {
            loadThemeByIdOrNull("trime")?.let {
                Timber.w("Theme '$id' is unavailable, fallback to default theme 'trime'")
                return ResolvedTheme("trime", it)
            }
        }

        for (fallbackId in getAllThemes().map { it.configId }.distinct()) {
            loadThemeByIdOrNull(fallbackId)?.let {
                Timber.w("Theme '$id' is unavailable, fallback to available theme '$fallbackId'")
                return ResolvedTheme(fallbackId, it)
            }
        }

        error("No valid theme available")
    }

    // The xige theme used to ship as "sigma_IBM"; that id collides with copies kept by
    // the user, so it moved to its own name. Move existing selections over once.
    private fun migrateLegacyThemeSelection() {
        if (prefs.selectedTheme.getValue() != LEGACY_XIGE_THEME_ID) return
        val bundled =
            appContext.assets.list("shared")?.contains("$XIGE_THEME_ID.trime.yaml") == true
        if (bundled) {
            prefs.selectedTheme.setValue(XIGE_THEME_ID)
            Timber.i("Migrated the selected theme to $XIGE_THEME_ID")
        }
    }

    private fun evaluateActiveTheme(): Theme {
        migrateLegacyThemeSelection()
        val selectedThemeId = prefs.selectedTheme.getValue()
        val resolvedTheme = getThemeById(selectedThemeId)
        val newTheme = resolvedTheme.theme
        if (resolvedTheme.configId != selectedThemeId) {
            prefs.selectedTheme.setValue(resolvedTheme.configId)
        }
        KeyActionManager.resetCache()
        FontManager.resetCache(newTheme)
        ColorManager.switchTheme(newTheme)
        LiquidData.init(newTheme)
        return newTheme
    }

    fun init(configuration: Configuration) {
        ensureActiveTheme()
        ColorManager.init(configuration)
    }

    fun selectTheme(configId: String) {
        val resolvedTheme = getThemeById(configId)
        val theme = resolvedTheme.theme
        KeyActionManager.resetCache()
        FontManager.resetCache(theme)
        ColorManager.switchTheme(theme)
        LiquidData.init(theme)
        activeTheme = theme
        prefs.selectedTheme.setValue(resolvedTheme.configId)
    }
}
