/*
 * SPDX-FileCopyrightText: 2026 Sprime contributors
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

package com.osfans.trime.ai.provider

import com.osfans.trime.ai.agent.ToolSpec
import com.osfans.trime.ai.model.AiDelta
import com.osfans.trime.ai.model.ChatMessage
import com.osfans.trime.ai.model.ChatRole
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.currentCoroutineContext
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.FlowCollector
import kotlinx.coroutines.flow.flow
import kotlinx.coroutines.flow.flowOn
import kotlinx.coroutines.isActive
import kotlinx.coroutines.job
import kotlinx.serialization.json.Json
import kotlinx.serialization.json.JsonArray
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
        tools: List<ToolSpec> = emptyList(),
    ): Flow<AiDelta> = flow {
        if (config.baseUrl.isBlank()) {
            emit(AiDelta.Failure("Missing API endpoint"))
            return@flow
        }
        if (config.apiKey.isBlank() && !config.baseUrl.startsWith("http://127.0.0.1")) {
            emit(AiDelta.Failure("Missing API key"))
            return@flow
        }
        val call = client.newCall(buildRequest(config, messages, tools))
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
                    val root = json.parseToJsonElement(source.readUtf8()).jsonObject
                    val text = parseContent(root)
                    if (!text.isNullOrEmpty()) emit(AiDelta.Text(text))
                    parseToolCalls(root)?.let { emit(AiDelta.ToolCalls(it)) }
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
        val toolCalls = LinkedHashMap<Int, MutableToolCall>()
        while (currentCoroutineContext().isActive) {
            val line = source.readUtf8Line() ?: break
            val payload = parser.feed(line) ?: continue
            if (payload == "[DONE]") break
            val root = json.parseToJsonElement(payload).jsonObject
            val delta = root.choicesDelta()
            delta?.reasoning?.takeIf { it.isNotEmpty() }?.let { collector.emit(AiDelta.Reasoning(it)) }
            delta?.content?.takeIf { it.isNotEmpty() }?.let { collector.emit(AiDelta.Text(it)) }
            root.choicesToolCallDeltas().forEach { part ->
                val entry = toolCalls.getOrPut(part.index) { MutableToolCall() }
                part.id?.let { entry.id = it }
                part.name?.let { entry.name = it }
                part.arguments?.let { entry.arguments.append(it) }
            }
        }
        toolCallsJson(toolCalls)?.let { collector.emit(AiDelta.ToolCalls(it)) }
    }

    private data class Delta(
        val content: String?,
        val reasoning: String?,
    )

    private data class ToolCallDelta(
        val index: Int,
        val id: String?,
        val name: String?,
        val arguments: String?,
    )

    private class MutableToolCall(
        var id: String? = null,
        var name: String? = null,
        val arguments: StringBuilder = StringBuilder(),
    )

    private fun JsonObject.choicesDelta(): Delta? {
        val choices = this["choices"]?.jsonArray ?: return null
        val first = choices.firstOrNull()?.jsonObject ?: return null
        val delta = first["delta"]?.jsonObject
        if (delta != null) {
            return Delta(
                content = delta["content"]?.jsonPrimitive?.contentOrNull,
                reasoning = delta["reasoning_content"]?.jsonPrimitive?.contentOrNull,
            )
        }
        val message = first["message"]?.jsonObject ?: return null
        return Delta(
            content = message["content"]?.jsonPrimitive?.contentOrNull,
            reasoning = null,
        )
    }

    private fun JsonObject.choicesToolCallDeltas(): List<ToolCallDelta> {
        val choices = this["choices"]?.jsonArray ?: return emptyList()
        val first = choices.firstOrNull()?.jsonObject ?: return emptyList()
        val delta = first["delta"]?.jsonObject ?: return emptyList()
        val calls = delta["tool_calls"]?.jsonArray ?: return emptyList()
        return calls.mapNotNull { element ->
            val obj = element.jsonObject
            val index = obj["index"]?.jsonPrimitive?.contentOrNull?.toIntOrNull() ?: 0
            val function = obj["function"]?.jsonObject
            ToolCallDelta(
                index = index,
                id = obj["id"]?.jsonPrimitive?.contentOrNull,
                name = function?.get("name")?.jsonPrimitive?.contentOrNull,
                arguments = function?.get("arguments")?.jsonPrimitive?.contentOrNull,
            )
        }
    }

    private fun toolCallsJson(calls: Map<Int, MutableToolCall>): String? {
        if (calls.isEmpty()) return null
        val array =
            buildJsonArray {
                calls.toSortedMap().forEach { (index, call) ->
                    val name = call.name ?: return@forEach
                    add(
                        buildJsonObject {
                            put("id", call.id ?: "call_" + index)
                            put("type", "function")
                            put(
                                "function",
                                buildJsonObject {
                                    put("name", name)
                                    put("arguments", call.arguments.toString().ifBlank { "{}" })
                                },
                            )
                        },
                    )
                }
            }
        return if (array.isEmpty()) null else array.toString()
    }

    private fun parseContent(root: JsonObject): String? {
        val choices = root["choices"]?.jsonArray ?: return null
        val first = choices.firstOrNull()?.jsonObject ?: return null
        first["delta"]?.jsonObject?.get("content")?.jsonPrimitive?.contentOrNull?.let { return it }
        return first["message"]?.jsonObject?.get("content")?.jsonPrimitive?.contentOrNull
    }

    private fun parseToolCalls(root: JsonObject): String? {
        val choices = root["choices"]?.jsonArray ?: return null
        val first = choices.firstOrNull()?.jsonObject ?: return null
        val message = first["message"]?.jsonObject ?: return null
        val calls = message["tool_calls"]?.jsonArray ?: return null
        if (calls.isEmpty()) return null
        return calls.toString()
    }

    private fun buildRequest(
        config: AiRequestConfig,
        messages: List<ChatMessage>,
        tools: List<ToolSpec>,
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
                        messages.forEach { message -> add(message.toJson()) }
                    },
                )
                if (tools.isNotEmpty()) {
                    put(
                        "tools",
                        buildJsonArray {
                            tools.forEach { spec ->
                                add(
                                    buildJsonObject {
                                        put("type", "function")
                                        put(
                                            "function",
                                            buildJsonObject {
                                                put("name", spec.name)
                                                put("description", spec.description)
                                                put("parameters", json.parseToJsonElement(spec.parameters.toString()))
                                            },
                                        )
                                    },
                                )
                            }
                        },
                    )
                    put("tool_choice", "auto")
                }
            }
        val endpoint = config.baseUrl.trimEnd('/') + "/chat/completions"
        return Request.Builder()
            .url(endpoint)
            .header("Authorization", "Bearer " + config.apiKey)
            .header("Content-Type", "application/json")
            .post(payload.toString().toRequestBody("application/json".toMediaType()))
            .build()
    }

    private fun ChatMessage.toJson(): JsonObject =
        buildJsonObject {
            put("role", role.wireName)
            when (role) {
                ChatRole.TOOL -> {
                    put("content", content)
                    toolCallId?.let { put("tool_call_id", it) }
                    name?.let { put("name", it) }
                }
                else -> {
                    val toolCallsJson = toolCalls
                    if (!toolCallsJson.isNullOrBlank()) {
                        put("tool_calls", json.parseToJsonElement(toolCallsJson))
                        put("content", if (content.isEmpty()) "" else content)
                    } else {
                        val image = image
                        if (image.isNullOrEmpty()) {
                            put("content", content)
                        } else {
                            put(
                                "content",
                                buildJsonArray {
                                    add(
                                        buildJsonObject {
                                            put("type", "text")
                                            put("text", content)
                                        },
                                    )
                                    add(
                                        buildJsonObject {
                                            put("type", "image_url")
                                            put(
                                                "image_url",
                                                buildJsonObject {
                                                    put("url", "data:image/jpeg;base64," + image)
                                                },
                                            )
                                        },
                                    )
                                },
                            )
                        }
                    }
                }
            }
        }
}
