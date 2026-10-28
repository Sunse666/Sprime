/*
 * SPDX-FileCopyrightText: 2026 Sprime contributors
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

package com.osfans.trime.ime.ai

import android.graphics.Color
import android.graphics.Typeface
import android.view.Gravity
import android.view.View
import android.widget.LinearLayout
import android.widget.ScrollView
import android.widget.TextView
import androidx.core.graphics.ColorUtils
import androidx.lifecycle.lifecycleScope
import com.osfans.trime.R
import com.osfans.trime.ai.AiController
import com.osfans.trime.ai.AiPanelState
import com.osfans.trime.ai.prompt.AiAction
import com.osfans.trime.data.theme.ColorManager
import com.osfans.trime.ime.core.TrimeInputMethodService
import com.osfans.trime.ime.keyboard.KeyboardWindow
import com.osfans.trime.ime.window.BoardWindow
import com.osfans.trime.ime.window.BoardWindowManager
import kotlinx.coroutines.Job
import kotlinx.coroutines.launch
import org.kodein.di.instance
import splitties.dimensions.dp

/**
 * AI panel page. It takes over the keyboard area at the same height, so opening
 * it never changes the IME insets.
 */
class AiPageWindow : BoardWindow.NoBarBoardWindow() {
    private val windowManager: BoardWindowManager by di.instance()
    private val service: TrimeInputMethodService by di.instance()
    private val aiController: AiController by di.instance()

    private lateinit var bodyView: TextView
    private lateinit var thinkingHeader: TextView
    private lateinit var thinkingBody: TextView
    private lateinit var statusView: TextView
    private lateinit var primaryButton: TextView
    private lateinit var secondaryButton: TextView
    private lateinit var chipsView: View
    private var thinkingExpanded = false
    private var lastState: AiPanelState? = null
    private var renderJob: Job? = null

    override fun onCreateView(): View {
        val textColor = color("key_text_color", Color.WHITE)
        val dimColor = ColorUtils.setAlphaComponent(textColor, 0x99)
        val background = color("keyboard_back_color", Color.BLACK)

        val root =
            LinearLayout(context).apply {
                orientation = LinearLayout.VERTICAL
                setBackgroundColor(background)
                setPadding(context.dp(16), context.dp(12), context.dp(16), context.dp(12))
            }

        val header =
            LinearLayout(context).apply {
                orientation = LinearLayout.HORIZONTAL
                gravity = Gravity.CENTER_VERTICAL
            }
        header.addView(
            TextView(context).apply {
                text = context.getString(R.string.ai_panel_title)
                textSize = 17f
                typeface = Typeface.DEFAULT_BOLD
                setTextColor(textColor)
            },
            LinearLayout.LayoutParams(0, LinearLayout.LayoutParams.WRAP_CONTENT, 1f),
        )
        header.addView(
            actionButton(textColor) { aiController.newConversation() }.apply {
                text = context.getString(R.string.ai_new_chat)
                textSize = 13f
            },
        )
        root.addView(
            header,
            LinearLayout.LayoutParams(
                LinearLayout.LayoutParams.MATCH_PARENT,
                LinearLayout.LayoutParams.WRAP_CONTENT,
            ),
        )

        chipsView = buildChips(textColor)
        root.addView(
            chipsView,
            LinearLayout.LayoutParams(
                LinearLayout.LayoutParams.MATCH_PARENT,
                LinearLayout.LayoutParams.WRAP_CONTENT,
            ).also { it.topMargin = context.dp(6) },
        )

        thinkingHeader =
            TextView(context).apply {
                textSize = 12f
                setTextColor(dimColor)
                visibility = View.GONE
                setPadding(0, context.dp(4), 0, context.dp(2))
                setOnClickListener {
                    if (!thinkingExpanded && thinkingBody.text.isBlank()) return@setOnClickListener
                    thinkingExpanded = !thinkingExpanded
                    updateThinking()
                }
            }

        thinkingBody =
            TextView(context).apply {
                textSize = 12f
                setTextColor(dimColor)
                setLineSpacing(context.dp(2).toFloat(), 1f)
                visibility = View.GONE
                setPadding(0, 0, 0, context.dp(6))
            }

        bodyView =
            TextView(context).apply {
                textSize = 15f
                setTextColor(textColor)
                setLineSpacing(context.dp(3).toFloat(), 1f)
            }

        val column =
            LinearLayout(context).apply {
                orientation = LinearLayout.VERTICAL
                addView(thinkingHeader, LinearLayout.LayoutParams.MATCH_PARENT, LinearLayout.LayoutParams.WRAP_CONTENT)
                addView(thinkingBody, LinearLayout.LayoutParams.MATCH_PARENT, LinearLayout.LayoutParams.WRAP_CONTENT)
                addView(bodyView, LinearLayout.LayoutParams.MATCH_PARENT, LinearLayout.LayoutParams.WRAP_CONTENT)
            }
        root.addView(
            ScrollView(context).apply {
                isFillViewport = true
                addView(
                    column,
                    LinearLayout.LayoutParams(
                        LinearLayout.LayoutParams.MATCH_PARENT,
                        LinearLayout.LayoutParams.WRAP_CONTENT,
                    ),
                )
            },
            LinearLayout.LayoutParams(
                LinearLayout.LayoutParams.MATCH_PARENT,
                0,
                1f,
            ).also { it.topMargin = context.dp(8) },
        )

        statusView =
            TextView(context).apply {
                textSize = 12f
                setTextColor(dimColor)
                setPadding(0, context.dp(6), 0, context.dp(6))
            }
        root.addView(statusView)

        val actions =
            LinearLayout(context).apply {
                orientation = LinearLayout.HORIZONTAL
                gravity = Gravity.END
            }
        primaryButton = actionButton(textColor) { onPrimaryAction() }
        secondaryButton = actionButton(textColor) { onSecondaryAction() }.apply { visibility = View.GONE }
        actions.addView(secondaryButton)
        actions.addView(primaryButton)
        actions.addView(
            actionButton(textColor) {
                windowManager.attachWindow(KeyboardWindow)
            }.apply { text = context.getString(R.string.ai_back_to_keyboard) },
        )
        root.addView(actions)

        return root
    }

    private fun buildChips(textColor: Int): View {
        val row = LinearLayout(context).apply { orientation = LinearLayout.HORIZONTAL }
        AiAction.entries.forEach { action ->
            row.addView(
                TextView(context).apply {
                    text = context.getString(action.labelRes)
                    textSize = 14f
                    setTextColor(textColor)
                    setPadding(context.dp(12), context.dp(6), context.dp(12), context.dp(6))
                    setOnClickListener { aiController.runAction(action) }
                },
            )
        }
        return row
    }

    private fun actionButton(
        color: Int,
        onClick: () -> Unit,
    ): TextView = TextView(context).apply {
        setTextColor(color)
        textSize = 14f
        gravity = Gravity.CENTER
        setPadding(context.dp(14), context.dp(10), context.dp(14), context.dp(10))
        setOnClickListener { onClick() }
    }

    private fun color(
        key: String,
        fallback: Int,
    ): Int = runCatching { ColorManager.getColor(key) }.getOrDefault(fallback)

    override fun onAttached() {
        render(aiController.state.value)
        renderJob =
            service.lifecycleScope.launch {
                aiController.state.collect { render(it) }
            }
    }

    override fun onDetached() {
        renderJob?.cancel()
        renderJob = null
    }

    private fun render(state: AiPanelState) {
        if (!::bodyView.isInitialized) return
        secondaryButton.visibility = View.GONE
        chipsView.visibility = if (state is AiPanelState.Idle) View.VISIBLE else View.GONE
        if (state is AiPanelState.Streaming && lastState !is AiPanelState.Streaming) {
            thinkingExpanded = false
        }
        lastState = state

        when (state) {
            is AiPanelState.Idle -> {
                bodyView.text = context.getString(R.string.ai_panel_hint)
                statusView.text = ""
                primaryButton.text = context.getString(R.string.ai_compose_entry)
                setThinking("")
            }

            is AiPanelState.Streaming -> {
                bodyView.text = state.text
                setThinking(state.thinking)
                statusView.text = context.getString(R.string.ai_status_streaming)
                primaryButton.text = context.getString(R.string.ai_stop)
            }

            is AiPanelState.Done -> {
                bodyView.text = state.text
                setThinking(state.thinking)
                statusView.text = context.getString(R.string.ai_status_done)
                primaryButton.text = context.getString(R.string.ai_insert)
                secondaryButton.text = context.getString(R.string.ai_copy)
                secondaryButton.visibility = View.VISIBLE
            }

            is AiPanelState.Error -> {
                bodyView.text = state.message
                setThinking("")
                statusView.text = context.getString(R.string.ai_status_error)
                primaryButton.text = context.getString(R.string.ai_retry)
            }

            is AiPanelState.Inserted -> {
                bodyView.text = state.text
                setThinking("")
                statusView.text = context.getString(R.string.ai_status_inserted)
                primaryButton.text = context.getString(R.string.ai_undo)
            }
        }
    }

    private fun setThinking(text: String) {
        thinkingBody.text = text
        updateThinking()
    }

    private fun updateThinking() {
        if (thinkingBody.text.isBlank()) {
            thinkingHeader.visibility = View.GONE
            thinkingBody.visibility = View.GONE
            return
        }
        thinkingHeader.visibility = View.VISIBLE
        val label = context.getString(R.string.ai_thinking_label)
        thinkingHeader.text = if (thinkingExpanded) "$label ▾" else "$label ▸"
        thinkingBody.visibility = if (thinkingExpanded) View.VISIBLE else View.GONE
    }

    private fun onPrimaryAction() {
        when (aiController.state.value) {
            is AiPanelState.Streaming -> aiController.stop()
            is AiPanelState.Idle -> aiController.startInputFromPanel()
            is AiPanelState.Done -> aiController.insertAnswer()
            is AiPanelState.Inserted -> aiController.undoLastCommit()
            else -> aiController.retry()
        }
    }

    private fun onSecondaryAction() {
        if (aiController.state.value is AiPanelState.Done) aiController.copyAnswer()
    }
}
