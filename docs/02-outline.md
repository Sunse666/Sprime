# Sprime 开发大纲 v1.0

> 前置文档：[01 架构与技术方案分析](01-architecture-analysis.md)
> 本文是**落地大纲**：把已定决策展开成可执行的任务卡与验收标准。
> 状态：定稿待开工 · 预估总量 18–25 人日（不含等待下载）

---

## 1. 产品

### 1.1 一句话

Sprime 是一个基于 Rime 的 Android 输入法，在**不新开窗口、不改变键盘高度**的前提下，把 AI 问答嵌进输入法本身。

### 1.2 核心场景

| # | 场景 | 用户动作 | 期望结果 |
|---|---|---|---|
| S1 | 翻译选中文字 | 选词 → 点顶栏 AI → 点"翻译" | 译文流式出现 → 一键替换 |
| S2 | 润色 / 改写 | 同上 | 改写文本 → 替换 |
| S3 | 自由提问 | 点 AI → 点“输入问题” → 打字（拼音可用）→ 回车 | 回答出现在 AI 页 → 插入 |
| S4 | 回复建议 | 在聊天框点亮 AI → "回复" | 3 条候选回复 → 点选插入 |

### 1.3 非目标（v1 明确不做）

- 不做语音输入、不做图片/多模态、不做联网搜索
- 不做内置免费额度（纯 BYOK）
- 不做多设备同步 / 云历史
- 不做整包重命名（Kotlin 包保持 com.osfans.trime）
- 不改 native（不碰 librime / JNI）

---

## 2. 硬约束（P0，任何 PR 不得违反）

| # | 约束 | 验收方式 |
|---|---|---|
| C1 | 一个窗口：只有原 IME 窗口，不新增 PopupWindow/Dialog/Activity | adb dumpsys window 前后对比 |
| C2 | 总高恒定：打字 / 开 AI / 切页 / 流式输出，insets 数值不变 | 代码审查 + 真机日志 |
| C3 | 不申请 overlay / 无障碍 / 截屏 / 前台服务权限 | 合并前扫 Manifest |
| C4 | GPL-3.0-or-later：新文件带 SPDX 头，README 声明来源 | 文件头检查 |
| C5 | 不上传密码框内容；未配置 key 时不发任何请求 | 单测 + 手测 |
| C6 | IME 主线程不做网络/磁盘 IO | 代码审查 |

---

## 3. 已定决策

| 编号 | 决策 | 取值 |
|---|---|---|
| D1 | 形态 | 固定总高 IME + 常驻顶栏 + AI 整页切换 |
| D2 | 竖屏尺寸 | 顶栏 48 + 候选栏 40 + 键盘 250 = **338dp**；横屏隐藏顶栏 |
| D3 | 外部可观测 | 仅"包名 + 恒定高度"，无任何状态信号 |
| D4 | 基线 | trime **v3.3.12**（compileSdk 36 / NDK 28 / AGP 9.3.0） |
| D5 | 包名 | applicationId = `com.sprime.ime`，Kotlin 包保留 `com.osfans.trime` |
| D6 | 分发 | GitHub 开源 + 自签 APK |
| D7 | AI 接入 | BYOK；OpenAI 兼容；预设 DeepSeek 等 |
| D8 | 隐私 | 默认不存历史、不读剪贴板；密码框禁用 AI |
| D9 | i18n | 中英双语资源，中文为默认 |
| D10 | 会话 | v1 单轮 + 追问按钮；Markdown 渲染留 v1.1 |


---

## 4. 交互规格

### 4.1 布局（竖屏）

```text
总高 338dp（恒定，任何状态不变）
+--------------------------------------------------+
| 顶栏 48dp   [组合/提问文本 + 光标]        [AI] [x] |   <- 常驻
+--------------------------------------------------+
| 候选栏 40dp  （AI 页时隐藏，空间让给 AI 页）        |
+--------------------------------------------------+
| 主体 250dp                                        |
|   A. 键盘页：正常键盘（默认）                       |
|   B. AI 页：回答列表 + 底部按钮条（290dp，含候选栏） |
+--------------------------------------------------+
```

- 横屏（高度 < 480dp）：顶栏隐藏，总高 = 候选栏 + 键盘（主题 `keyboard_height_land` 决定）。
- 小屏（高度 < 600dp）：顶栏可降到 36dp（设置项），仍是常量。

### 4.2 顶栏三态

| 状态 | 左侧显示 | 右侧按钮 | 触发 |
|---|---|---|---|
| Normal | Rime 组合文本（拼音/预编辑）；空时显示占位"AI" | [AI] | 默认 |
| Ask | 提问缓冲 + 闪烁光标 + 组合预览 | [发送] [×] | 点 AI 后自动进入 |
| Answer | 本轮提问摘要（单行滚动） | [键盘] [×] | 切到 AI 页时 |

顶栏点击：Normal 态点文字区 = 进入 Ask；Ask 态点文字区 = 无操作（光标只显示不编辑）。

### 4.3 AI 页四态

| 状态 | 内容 | 底部按钮 |
|---|---|---|
| Idle | 动作 chips（翻译/润色/总结/解释/回复/继续，有选区时高亮）+ 大号"输入问题"入口；未配置 Key 时显示引导文案 | [去配置]（可选，显式点击才开设置页） |
| Streaming | 流式回答 + 光标动画 | [停止] |
| Done | 完整回答 | [插入] [替换] [复制] [重试] [追问] |
| Error | 错误码 + 人话解释 + 请求 ID | [重试] [复制错误] |

### 4.4 入口与退出

| 动作 | 行为 |
|---|---|
| 点顶栏 [AI] | 切到 AI 页 Idle（chips + 提问入口），键盘隐藏 |
| 点 AI 页里的"输入问题" | 回键盘页并进入 Ask 态 |
| 长按顶栏 [AI] / 键盘 AI 键（主题 `preset_keys`） | 直接进入 Ask 态 |
| 回车（Ask 态） | 发送 → 切 AI 页 |
| 点 [键盘] | 回键盘页，保留本次提问 |
| 点 [×] / 切到别的 App / `onFinishInputView` | 退出 AI 模式，清空缓冲 |
| 点 App 输入框（`onViewClicked`） | 退出 Ask 模式，回到普通输入 |

### 4.5 插入语义

- 有选区 → **替换**选区（`commitText` 天然覆盖选区）
- 无选区 → 插入到光标处
- 插入后自动回键盘页，并清空提问
- 可撤销：复用 trime 已有 `performContextMenuAction(android.R.id.undo)`

### 4.6 Ask 模式按键规则

| 按键 | 行为 |
|---|---|
| 字母/数字键 | Rime 照常处理，**上屏文本进缓冲，不进 App** |
| 选候选（点按或数字键） | 同上，提交进缓冲 |
| 空格 | Rime 决定（通常是上屏首候选）→ 进缓冲 |
| BackSpace（组合态） | Rime 自己删拼音 |
| BackSpace（非组合态） | 删缓冲末字符 |
| Enter | 发送 |
| 方向键 / Home / End | v1 忽略（缓冲只支持尾插/尾删） |
| 符号页 / 表情 | 正常插入缓冲 |
| 长按 / 滑动 | 与现有键盘一致 |

### 4.7 状态机

```text
Closed --(点 AI)--> Idle[AI 页] --(点 chip)--> Streaming --> Done --(插入/替换)--> Closed
                      |    ^                        |
        (点"输入问题") |    | (点键盘)                | (出错) --> Error --(重试)--> Streaming
                      v    |                        |
                   Ask[键盘页] --(回车)--> Streaming  |
                      |                             |
                      +--(点 x / 切 App / finishInput)--+--> Closed
```

---

## 5. 技术架构

### 5.1 分层

```text
┌ UI 层 ──────────────────────────────────────────────┐
│ AiStripView（顶栏）   AiPageView（AI 页，BoardWindow）│
└──────────────┬──────────────────────────────────────┘
               │ StateFlow / 事件
┌ 控制层 ──────┴──────────────────────────────────────┐
│ AiController：状态机、上屏重定向、生命周期、取消      │
└──────────────┬──────────────────────────────────────┘
               │
┌ 领域层 ──────┴──────────────────────────────────────┐
│ Conversation（消息列表）  PromptBuilder  ContextBuilder│
│ BufferEditor（提问缓冲的编辑模型）                     │
└──────────────┬──────────────────────────────────────┘
               │
┌ 基础设施 ────┴──────────────────────────────────────┐
│ OpenAiCompatibleProvider  SseParser  KeyStore  Prefs  │
└─────────────────────────────────────────────────────┘
```

原则：UI 不碰网络，Provider 不认识 Android View，Controller 是唯一可变状态持有者。

### 5.2 模块职责

| 模块 | 职责 | 不做什么 |
|---|---|---|
| AiController | 状态机、开启/关闭、发送、取消、插入、与 Service 交互 | 不解析 SSE、不拼 prompt |
| BufferEditor | 提问文本的插入/删除/光标/长度上限 | 不渲染 |
| ContextBuilder | 选区/前后文/编辑器类型/包名 → 上下文对象 | 不发请求 |
| PromptBuilder | 动作模板 + 上下文注入 + 截断 | 不决定模型参数 |
| AiProvider | 一次请求 → `Flow<AiDelta>` | 不管 UI 状态 |
| SseParser | 字节流 → 增量文本（纯函数） | 不持有连接 |
| AiSettings | 读写 prefs / KeyStore | 不发起请求 |
| AiStripView | 三态渲染 + 点击 | 不持有业务状态 |
| AiPageView | 四态渲染 + 滚动 | 同上 |

### 5.3 线程与生命周期

- **主线程**：所有 View 操作、状态机迁移。
- **IO**：`Dispatchers.IO`，OkHttp 自带连接池；SSE 在 `Flow` 里 `flowOn(IO)`。
- **单飞**：同一时刻只允许一个进行中的请求；新请求自动取消旧请求。
- **取消时机**：点停止、`onFinishInputView`、退出 AI 模式、新问题、超时。
- **不取消**：切到键盘页（用户可能在边看边打字）。
- **存活范围**：AiController 挂在 Service 的 `lifecycleScope` 上，InputView 因换主题重建时状态不丢（View 从 StateFlow 重新绑定）。
- **进程被杀**：不做恢复（v1），重新拉起后回到 Idle。

### 5.4 与 trime 的边界

- 只做"加钩子"，不重构现有逻辑。
- 不改 Keyboard / KeyView / Theme 解析 / Rime JNI。
- 所有新代码放 `com.osfans.trime.ai` 与 `com.osfans.trime.ime.ai`，便于从上游 rebase。


---

## 6. 代码结构

```text
app/src/main/java/com/osfans/trime/
├── ai/                                  # 新增：业务层（不依赖 View）
│   ├── AiController.kt                  # 状态机 + 上屏重定向 + 取消
│   ├── AiSettings.kt                    # prefs + 密钥读写
│   ├── model/
│   │   ├── ChatMessage.kt               # role/content
│   │   ├── ChatRequest.kt               # messages + 参数
│   │   └── AiDelta.kt                   # Text/Reasoning/Done/Error
│   ├── provider/
│   │   ├── AiProvider.kt                # interface
│   │   ├── OpenAiCompatibleProvider.kt  # OkHttp + SSE
│   │   ├── SseParser.kt                 # 纯函数，单测重点
│   │   └── ProviderPresets.kt           # 预设服务商表
│   ├── prompt/
│   │   ├── AiAction.kt                  # 7 个动作枚举 + 默认指令
│   │   └── PromptBuilder.kt             # 模板 + 上下文 + 截断
│   ├── context/
│   │   ├── EditorContext.kt             # 选区/前后文/包名/inputType
│   │   └── ContextBuilder.kt            # 采集 + 裁剪 + 脱敏
│   └── input/BufferEditor.kt            # 提问缓冲编辑模型（纯 Kotlin）
├── ime/ai/                              # 新增：IME 层
│   ├── AiStripView.kt                   # 常驻顶栏（三态）
│   ├── AiStripController.kt             # 顶栏与状态机绑定
│   ├── AiPageWindow.kt                  # BoardWindow：AI 整页
│   ├── AiPageView.kt                    # 回答列表 + 底部按钮
│   ├── AiAnswerAdapter.kt               # RecyclerView 适配器（增量）
│   └── AiInputSink.kt                   # 接管 commit/key/enter/backspace
└── ui/main/settings/AiSettingsFragment.kt   # 设置页（PreferenceDelegateFragment）

app/src/main/res/
├── values/strings_ai.xml                # 中文
├── values-en/strings_ai.xml             # 英文
└── drawable/ic_ai_*.xml                 # 图标（矢量）
```

---

## 7. 对 trime 的改动清单

| # | 文件 | 改动 | 风险 |
|---|---|---|---|
| 1 | `ime/core/InputView.kt` | 在 `keyboardView` 内、`inputBar.view` 之上插入 `AiStripView`（48dp）；DI 注册 AiController/AiPageWindow；`refreshColors` 刷新顶栏 | 低 |
| 2 | `ime/core/TrimeInputMethodService.kt` | ① `commitText` 前置 sink 判断 ② `handleRimeMessage` KeyMessage 分支交给 sink ③ `handleReturnKey` 判断发送 ④ `onFinishInputView` 取消请求 ⑤ 暴露 `editorContext()` | **中**（上屏主路径，必须回归测试） |
| 3 | `ime/keyboard/CommonKeyboardActionListener.kt` | `handleFunctionCommand` 增加 `ai_assistant` | 低 |
| 4 | `data/prefs/AppPrefs.kt` | 新增 `class Ai : PreferenceDelegateOwner` | 低 |
| 5 | `AndroidManifest.xml` | 加 INTERNET 权限；label 改 Sprime | 低 |
| 6 | `app/build.gradle.kts` + `gradle/libs.versions.toml` | 加 okhttp、security-crypto | 低 |
| 7 | `app/src/main/res/values/strings.xml` + `values-zh` | app_name 等改名 | 低 |
| 8 | `ui/main/settings/` + 导航 | 新增 AI 设置页入口 | 低 |
| 9 | `assets/shared/trime.yaml`（自带主题副本） | 加 `AI: {label: AI, command: ai_assistant}` | 低 |
| 10 | `ui/main/MainActivity` 等 | 设置入口排序 | 低 |

> **不碰**：`onComputeInsets`、`onConfigureWindow`、Keyboard/KeyView、Theme 解析、JNI。

---

## 8. 数据与配置

### 8.1 偏好项（AppPrefs.Ai）

| key | 类型 | 默认 | 说明 |
|---|---|---|---|
| `ai_enabled` | switch | true | 总开关（关掉后顶栏仍常驻，仅显示组合文本） |
| `ai_provider` | list | deepseek | 预设服务商 |
| `ai_base_url` | string | 随预设 | 自定义时生效 |
| `ai_model` | string | 随预设 | 模型名 |
| `ai_key` | string（加密） | 空 | 见 8.2 |
| `ai_temperature` | int 0-100 | 30 | 实际除以 100 |
| `ai_max_tokens` | int | 1024 | |
| `ai_system_prompt` | string | 内置 | 可改 |
| `ai_context_enabled` | switch | true | 是否带上下文 |
| `ai_context_chars` | int | 2000 | 截断长度 |
| `ai_send_clipboard` | switch | false | 是否带剪贴板 |
| `ai_history_enabled` | switch | false | v1.1 才真正使用 |
| `ai_strip_height` | list | 48 | 36 / 48 / 64 |
| `ai_toolbar_button` | switch | true | 工具栏是否显示 AI 按钮 |
| `ai_allow_cleartext` | switch | false | 局域网 HTTP |
| `ai_stream` | switch | true | 关掉走非流式 |

### 8.2 密钥存储

- API 23+：`EncryptedSharedPreferences`（AES256-GCM，KeyStore 保护）
- API 21–22：降级普通 prefs，设置页显示风险提示
- 读取只发生在发请求前；不写日志、不进崩溃上报

### 8.3 服务商预设

| id | 名称 | baseUrl | 默认模型 |
|---|---|---|---|
| deepseek | DeepSeek | https://api.deepseek.com/v1 | deepseek-chat |
| openai | OpenAI | https://api.openai.com/v1 | gpt-4o-mini |
| moonshot | Kimi | https://api.moonshot.cn/v1 | moonshot-v1-8k |
| zhipu | 智谱 | https://open.bigmodel.cn/api/paas/v4 | glm-4-flash |
| dashscope | 通义 | https://dashscope.aliyuncs.com/compatible-mode/v1 | qwen-plus |
| openrouter | OpenRouter | https://openrouter.ai/api/v1 | （用户填） |
| ollama | Ollama（本机） | http://127.0.0.1:11434/v1 | qwen2.5:7b |
| custom | 自定义 | 用户填 | 用户填 |

### 8.4 动作与提示词

| 动作 | 指令模板（system 之外） |
|---|---|
| translate | 把下面内容翻译成{目标语言}，只输出译文，保留段落与格式。 |
| polish | 保持原意润色下面内容，语气{正式/自然}，输出改写结果。 |
| summarize | 用不超过{120}字总结下面内容的 3 个要点。 |
| explain | 用通俗的话解释下面内容，面向非专业读者。 |
| reply | 根据下面这段对话，生成 3 条简短回复，风格{自然}。 |
| continue | 接着下面内容续写一句话，保持语气一致，不超过 50 字。 |
| custom | （用户原话） |

上下文注入顺序：`system` → 上下文块（`<context>...`）→ 指令 → 可选"只输出结果，不要解释"。

### 8.5 会话模型

- v1：内存里的 `List<ChatMessage>`，关闭 AI 模式即清空
- 追问 = 追加 user 消息，重新请求
- 历史落盘（Room）留 v1.1，表结构预留：`session(id, startedAt, appPkg)`，`message(id, sessionId, role, content, ts)`


---

## 9. 关键流程

### 9.1 首次使用

```text
安装 → 设为默认输入法 → 打字（AI 未配置时一切照旧）
→ 点顶栏 AI → AI 页 Idle："还没有配置 AI 服务"
→ [去配置]（用户显式点击才打开设置页）→ 填 Key → [测试连接] → 保存
```

### 9.2 选区动作

```text
用户选中文字 → 点 AI → AI 页 Idle（chips 高亮"翻译"等）
→ 点"翻译" → Controller 采集选区 → PromptBuilder
→ Provider(SSE) → AI 页 Streaming → Done
→ 点"替换" → commitText → 回键盘页
```

### 9.3 自由提问

```text
点 AI → AI 页 Idle → 点"输入问题" → 回键盘页 + 顶栏 Ask
→ 打字（Rime 上屏进缓冲）→ 回车
→ 切 AI 页 Streaming → Done → [插入]
```

### 9.4 插入 / 替换 / 撤销

- 插入：`commitTextToEditor(answer)`（绕过 sink），清空会话，回键盘页
- 替换：同 commitText（选区存在时系统自动替换）
- 撤销：`ic.performContextMenuAction(android.R.id.undo)`
- 失败（编辑器只读/连接断开）：Toast + 保留回答，允许"复制"

### 9.5 异常

| 情况 | 处理 |
|---|---|
| 401/403 | 面板提示"Key 无效或过期"，给"去配置" |
| 429 | 提示限流，指数退避重试一次 |
| 5xx / 网络断 | 保留已收内容，显示"已中断"，可重试 |
| 超时（首 token 30s） | 取消并提示，可改非流式重试 |
| 流式中途断 | 保留前半段，标记"[已中断]" |
| 取消 | 立即停止 UI 更新，保留已有文本 |
| 未配置 Key | 请求直接短路，不发网络 |

---

## 10. 任务卡与里程碑

> 预估按 1 人单线程；有下载/构建等待的另计。

### M0 基线跑通（2–3 天）

| ID | 任务 | 验收 |
|---|---|---|
| M0-1 | clone v3.3.12 到 Sprime，remote 设 upstream=trime | git log/tag 正确 |
| M0-2 | 修符号链接（core.symlinks 或脚本实体化） | assets/shared 是真实 yaml |
| M0-3 | submodule 初始化（含 rime 数据） | jni 目录有源码 |
| M0-4 | 装 SDK 36 / build-tools 36 / NDK 28 / CMake 3.31.6 | gradle 能配置 |
| M0-5 | 改 applicationId、应用名、占位图标 | 可与 trime 共存安装 |
| M0-6 | 出 debug APK，真机打字 | 打字/候选/切方案正常 |

产出：可运行基线，打 tag `m0-base`。

### M1 骨架（3–4 天）

| ID | 任务 | 验收 |
|---|---|---|
| M1-1 | `AiStripView` 三态渲染（假数据） | 文字/光标/按钮正常 |
| M1-2 | InputView 插入顶栏，总高 338dp | 高度前后一致 |
| M1-3 | `AiPageWindow` 空页 + 切页 + 隐藏候选栏 | 进页/退页无闪烁 |
| M1-4 | `ai_assistant` 命令 + 顶栏按钮 + 主题按键 | 三种入口都能开 |
| M1-5 | 高度不变量日志 | 全流程 insets 恒定 |

产出：可见骨架，无 AI。

### M2 AI 链路（4–6 天）

| ID | 任务 | 验收 |
|---|---|---|
| M2-1 | `AppPrefs.Ai` + 设置页 + 密钥存储 | 重启后配置仍在 |
| M2-2 | Provider + 预设 + OkHttp | 可用 curl 对照 |
| M2-3 | `SseParser` + 单测（含分包/乱序/中断） | 覆盖率 > 90% |
| M2-4 | 非流式兜底 | 关流式可用 |
| M2-5 | AI 页流式渲染 + 停止/重试 | 首 token < 2s 显示 |

### M3 上下文与动作（3–5 天）

| ID | 任务 | 验收 |
|---|---|---|
| M3-1 | EditorContext 采集（选区/前后文/包名/inputType） | 微信/浏览器均取到 |
| M3-2 | PromptBuilder + 7 动作 | 输出符合预期 |
| M3-3 | AI 页 chips + 选中态 | 点 chip 直接请求 |
| M3-4 | 插入/替换/复制/撤销 | 文本落到光标处 |

### M4 自由提问（4–6 天）

| ID | 任务 | 验收 |
|---|---|---|
| M4-1 | `BufferEditor` + 单测 | 增删/上限/光标 |
| M4-2 | `AiInputSink`（commit/key/enter/backspace） | ASCII 也不漏到 App |
| M4-3 | 顶栏 Ask 态 + 组合预览 + 光标动画 | 拼音可见 |
| M4-4 | 键盘页 ⇄ AI 页状态同步 | 来回切换不丢内容 |

### M5 打磨与发布（4–6 天）

| ID | 任务 | 验收 |
|---|---|---|
| M5-1 | 密码框/敏感场景守卫 | 不发请求、入口置灰 |
| M5-2 | 主题配色 + i18n + 图标 | 换主题跟随 |
| M5-3 | 首次引导文案（不弹窗） | 无 AI 也能正常用 |
| M5-4 | README / LICENSE / NOTICE / 隐私说明 | 合规检查通过 |
| M5-5 | 签名 + release 构建 + GitHub Release | 可安装、可升级 |

**总计**：约 18–25 人日 + 环境下载时间。


---

## 11. 测试计划

### 11.1 单元测试（JVM，必须）

| 对象 | 用例 |
|---|---|
| SseParser | 正常分包、一行多包、`[DONE]`、半包、注释行、非法 JSON、空行 |
| BufferEditor | 追加、删除、上限截断、光标、清空 |
| PromptBuilder | 上下文截断、超长选区、空选区、动作模板渲染 |
| ContextBuilder | 密码框返回 null、`getSelectedText` 为 null 的降级 |
| ProviderPresets | baseUrl 拼接（尾斜杠/带路径） |

### 11.2 手工矩阵

| 维度 | 取值 |
|---|---|
| App | 微信、QQ、浏览器（Chrome/夸克）、备忘录、Gmail、Telegram、Word、支付宝、某银行、某手游 |
| 输入框 | 普通单行、多行、搜索、密码、数字、富文本、WebView、Compose |
| 方向 | 竖屏、横屏、分屏、折叠屏展开 |
| ROM | 原生（Pixel）、MIUI/HyperOS、ColorOS、Harmony/EMUI |
| 网络 | 正常、弱网、断网、飞行模式、代理 |

### 11.3 性能预算

- 按键延迟：与基线对比 P95 无回归（顶栏绘制不触发重排）
- 首 token：正常网络 < 2s；> 30s 提示超时
- 内存：常驻增量 < 20 MB
- 包体：增量 < 2 MB（OkHttp + security-crypto）

### 11.4 不变量测试（每次回归必跑）

1. `dumpsys window` 窗口数量前后一致
2. insets 高度在 打字/开页/流式 期间不变
3. 密码框内不发任何网络请求（抓包验证）
4. 强杀进程后重新唤起不崩溃

---

## 12. 发布与合规

| 项 | 内容 |
|---|---|
| 版本 | 0.1.0 / versionCode 1，语义化递增 |
| 产物 | `Sprime-0.1.0-<abi>.apk`，自签 keystore 离线保管 |
| 源码 | GitHub 公开仓库（GPL-3.0-or-later），release 附对应 tag |
| 声明 | README 写明基于 trime / Rime，附上游链接与许可证 |
| 文件头 | 所有新文件 `SPDX-License-Identifier: GPL-3.0-or-later` |
| 隐私 | 说明：文本会发送到用户自选的服务商；默认无历史；可关闭 |
| 不收集 | 不做遥测、不上报使用数据（v1） |
| 升级 | applicationId 固定，签名固定，保证可覆盖升级 |

---

## 13. 风险与对策（固定高度方案下更新）

| # | 风险 | 概率 | 对策 |
|---|---|---|---|
| 1 | 小屏/横屏顶栏挤压键盘 | 中 | 高度阈值自动隐藏；设置项可调 36/48/64 |
| 2 | Rime 组合文本在顶栏刷新不同步 | 中 | 监听 composition 流 + 16ms 节流；组合为空时显示占位 |
| 3 | Ask 模式"吞键"让用户困惑 | 中 | 顶栏高亮 + 光标 + [×]；点 App 输入框自动退出 |
| 4 | 长文本截断导致答非所问 | 中 | 截断点加提示"（已截断）"，设置可调 |
| 5 | 各家 SSE 格式差异 | 中 | 容错解析 + 非流式兜底 |
| 6 | BYOK 上手门槛高 | 中 | 预设 + 测试连接 + 一键复制示例配置 |
| 7 | 上游变更导致 rebase 冲突 | 低 | 新代码集中两个包，改动仅 8 个文件 |
| 8 | GPL 合规疏漏 | 低 | 发布脚本检查 SPDX 头 + 同步源码 tag |

---

## 14. 附录

### 14.1 命名与风格

- 新包：`com.osfans.trime.ai.%*`、`com.osfans.trime.ime.ai.%*`
- 资源前缀：`ai_`，字符串集中 `strings_ai.xml`
- 代码风格：沿用 spotless + ktlint 1.8.0（构建已配置）
- 提交信息：Conventional Commits（与 trime 一致）

### 14.2 分支模型

| 分支 | 用途 |
|---|---|
| `main` | 跟随 trime v3.3.x，保持可构建 |
| `feat/ai-core` | M1–M3 |
| `feat/ai-input` | M4 |
| `release/0.1` | 发布冻结 |

### 14.3 第三方主题兼容

- 第三方主题没有 `AI` 键：顶栏按钮仍然可用（顶栏不属于主题）
- 顶栏配色：优先取 `ThemeScope.colors`，缺失时用主题的 `key_text_color`
- 主题切换时只刷新颜色，不重建 AiController

### 14.4 v1.1 待办池

- 会话历史（Room）+ 可搜索
- 轻量 Markdown 渲染（粗体/代码块/列表）
- 一键"AI 联想"（InlineSuggestions）
- 本地模型（Ollama 一键探测）
- 多 provider 配置切换
- 语音提问

---

---

## 15. 工程约定（硬性）

### 16.1 提交

- **每个功能/修复完成即提交**，一个任务卡一次 commit，单次改动尽量 ≤ 400 行。
- 消息格式：Conventional Commits，**全英文**，type 小写，冒号后接小写描述，不超过 72 字符。
  - `feat(ai): add persistent strip view`
  - `feat(ai): stream openai-compatible responses`
  - `fix(ime): keep insets stable when switching to ai page`
  - `refactor(ai): extract prompt builder`
  - `test(ai): cover sse parser edge cases`
  - `build: replace asset symlinks with regular files`
  - `docs: add outline and architecture notes`
- 允许的 type：`feat` / `fix` / `refactor` / `test` / `build` / `docs` / `chore` / `perf`。
- **不 push**，推送由仓库所有者执行。
- 不使用 Co-Authored-By / AI 署名。
- 提交前必须：编译通过、相关单测通过、`spotlessCheck` 通过、无调试日志残留。

### 16.2 注释

- **一律英文**。
- **能省则省**：只在"为什么"不明显的地方写一行；不复述代码在做什么。
- 公共 API / 非显然算法允许一句 KDoc 或行内注释；其余不写。
- 禁止大段块注释、禁止注释掉的旧代码、禁止 `TODO` 不带原因。

```kotlin
// Good: explains the non-obvious ordering constraint.
if (composingText.isNotEmpty()) sink.commit(text) else commitToEditor(text)

// Bad: restates the line.
// set the text
textView.text = value
```

### 16.3 仓库卫生

- 不提交：`build/`、`.gradle/`、`local.properties`、keystore、API Key、任何 `*.apk`。
- 不修改无关文件；对 trime 上游文件的改动必须能用一句话说清目的（便于 rebase）。
- 新增文件一律带 SPDX 头。

### 16.4 分支

- 默认分支 `main`，跟随 trime `v3.3.12` 基线。
- 功能分支：`feat/ai-core`、`feat/ai-input`。


## 16. 下一步

1. 执行 M0-1 ~ M0-6（环境与基线）
2. M1-1 ~ M1-5 出可点骨架
3. M2 打通 DeepSeek 流式

> 本文与 [01 分析](01-architecture-analysis.md) 冲突时，以本文（含 §13 决策记录）为准。
