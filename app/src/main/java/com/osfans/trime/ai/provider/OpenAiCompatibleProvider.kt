/*
 * SPDX-FileCopyrightText: 2026 Sprime contributors
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

package com.osfans.trime.ai.provider

import com.osfans.trime.ai.model.AiDelta
import com.osfans.trime.ai.model.ChatMessage
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.currentCoroutineContext
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.FlowCollector
import kotlinx.coroutines.flow.flow
import kotlinx.coroutines.flow.flowOn
import kotlinx.coroutines.isActive
import kotlinx.coroutines.job
import kotlinx.serialization.json.Json
import kotlinx.serialization.json.JsonObject
import kotlinx.serialization.json.add
import kotlinx.serialization.json.buildJsonArray
import kotlinx.serialization.json.buildJsonObject
import kotlinx.serialization.json.contentOrNull
import kotlinx.serialization.json.jsonArray
import kotlinx.serialization.json.jsonObject
import kotlinx.serialization.json.jsonPrimitive
import kotlinx.serialization.json.put
import okhttp3.MediaType.Companion.toMediaType
import okhttp3.OkHttpClient
import okhttp3.Request
import okhttp3.RequestBody.Companion.toRequestBody
import okio.BufferedSource
import java.io.IOException
import java.util.concurrent.TimeUnit

data class AiRequestConfig(
    val baseUrl: String,
    val apiKey: String,
    val model: String,
    val temperature: Double = 0.3,
    val maxTokens: Int = 1024,
    val stream: Boolean = true,
)

class OpenAiCompatibleProvider {
    private val json = Json { ignoreUnknownKeys = true }

    private val client =
        OkHttpClient.Builder()
            .connectTimeout(15, TimeUnit.SECONDS)
            .readTimeout(120, TimeUnit.SECONDS)
            .build()

    fun chat(
        config: AiRequestConfig,
        messages: List<ChatMessage>,
    ): Flow<AiDelta> = flow {
        if (config.baseUrl.isBlank()) {
            emit(AiDelta.Failure("Missing API endpoint"))
            return@flow
        }
        if (config.apiKey.isBlank() && !config.baseUrl.startsWith("http://127.0.0.1")) {
            emit(AiDelta.Failure("Missing API key"))
            return@flow
        }
        val call = client.newCall(buildRequest(config, messages))
        currentCoroutineContext().job.invokeOnCompletion { call.cancel() }
        try {
            call.execute().use { response ->
                if (!response.isSuccessful) {
                    val detail = response.body?.string()?.take(300).orEmpty()
                    emit(AiDelta.Failure("HTTP " + response.code + ": " + detail))
                    return@use
                }
                val source = response.body?.source()
                if (source == null) {
                    emit(AiDelta.Failure("Empty response"))
                    return@use
                }
                if (config.stream) {
                    readStream(source, this)
                } else {
                    val text = parseContent(json.parseToJsonElement(source.readUtf8()).jsonObject)
                    if (!text.isNullOrEmpty()) emit(AiDelta.Text(text))
                }
            }
            emit(AiDelta.Done)
        } catch (e: IOException) {
            emit(AiDelta.Failure(e.message ?: "Network error"))
        }
    }.flowOn(Dispatchers.IO)

    private suspend fun readStream(
        source: BufferedSource,
        collector: FlowCollector<AiDelta>,
    ) {
        val parser = SseParser()
        while (currentCoroutineContext().isActive) {
            val line = source.readUtf8Line() ?: break
            val payload = parser.feed(line) ?: continue
            if (payload == "[DONE]") break
            val content = parseContent(json.parseToJsonElement(payload).jsonObject) ?: continue
            if (content.isNotEmpty()) collector.emit(AiDelta.Text(content))
        }
    }

    private fun parseContent(root: JsonObject): String? {
        val choices = root["choices"]?.jsonArray ?: return null
        val first = choices.firstOrNull()?.jsonObject ?: return null
        first["delta"]?.jsonObject?.get("content")?.jsonPrimitive?.contentOrNull?.let { return it }
        return first["message"]?.jsonObject?.get("content")?.jsonPrimitive?.contentOrNull
    }

    private fun buildRequest(
        config: AiRequestConfig,
        messages: List<ChatMessage>,
    ): Request {
        val payload =
            buildJsonObject {
                put("model", config.model)
                put("stream", config.stream)
                put("temperature", config.temperature)
                put("max_tokens", config.maxTokens)
                put(
                    "messages",
                    buildJsonArray {
                        messages.forEach { message ->
                            add(
                                buildJsonObject {
                                    put("role", message.role.wireName)
                                    put("content", message.content)
                                },
                            )
                        }
                    },
                )
            }
        val endpoint = config.baseUrl.trimEnd('/') + "/chat/completions"
        return Request.Builder()
            .url(endpoint)
            .header("Authorization", "Bearer " + config.apiKey)
            .header("Content-Type", "application/json")
            .post(payload.toString().toRequestBody("application/json".toMediaType()))
            .build()
    }
}
