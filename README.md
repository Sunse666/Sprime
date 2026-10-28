# Sprime

基于 Rime（trime / librime）的 Android 输入法，内嵌 AI 助手：在输入法内直接提问与取用回答，不新开窗口、不改变键盘高度。

> 状态：**方案与大纲已定稿，待开工**
> 参考实现：[trime](https://github.com/osfans/trime)（GPL-3.0-or-later，基线 v3.3.12）
> 许可证：本项目同样以 **GPL-3.0-or-later** 发布

## 文档

| 文档 | 内容 |
|---|---|
| [01 架构分析](docs/01-architecture-analysis.md) | 可行性判断、trime 改造点、窗口可检测性、构建环境实测、决策记录 |
| [02 开发大纲](docs/02-outline.md) | 交互规格、代码结构、改动清单、配置项、流程、任务卡与验收、测试与发布 |

## 关键决策（摘要）

- 形态：固定总高 IME（竖屏 338dp）+ 常驻 48dp 顶栏 + AI 整页切换，insets 全程不变
- 外部可观测性：仅"输入法包名 + 恒定高度"，不新增窗口、不申请 overlay 权限
- 基线：trime v3.3.12；applicationId = com.sprime.ime；Kotlin 包保留 com.osfans.trime
- AI：BYOK + OpenAI 兼容 + 预设（默认 DeepSeek），默认不存历史、不上传剪贴板、密码框禁用
- 分发：GitHub 开源 + 自签 APK
