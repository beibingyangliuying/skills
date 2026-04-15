# State And Timestamps

## 目标

让 roadmap 的状态字段和时间字段保持一致，避免历史计划与现行计划混淆，也避免同一天内多次更新无法分辨先后的问题。

## 状态定义

- `active`: 当前仍然有效、可继续指导后续实现或下一步决策的 roadmap。
- `draft`: 仍在探索、尚未成为正式执行依据的 roadmap。
- `completed`: 主体目标已完成，roadmap 保留为历史记录。
- `superseded`: 原路线已被新路线明确替代，不再作为现行执行依据。

## 字段规范

- MUST: 每份 roadmap 默认至少包含 `Status`、`Scope`、`Last updated`。
- MUST: `Superseded by` 仅在该 roadmap 已被新 roadmap 接管时填写。
- MUST: `Next roadmap` 仅在已经明确存在后继路线时填写，不作为默认必填。
- MUST: `Final note` 用于说明为什么结束、完成到什么程度、或为什么被替代。
- SHOULD: `Related roadmaps` 只保留少量真正有关联的文档，不要把它变成链接堆。

## 字段出现条件

- 所有 roadmap 默认有：
  - `Status`
  - `Scope`
  - `Last updated`
- `active / draft` 常用：
  - `Current state`
  - `Plan`
  - `Progress update`
  - `Open questions`
  - `Risks / watchlist`
- `completed` 常用：
  - `Completed at`
  - `Final note`
  - 可选 `Next roadmap`
- `superseded` 常用：
  - `Superseded at`
  - `Superseded by`
  - `Final note`
- MUST NOT: 不要用 `—` 之类的占位符伪装成字段存在。
- MUST: 若关系尚不存在，就不要写该字段。
- MUST: `Next roadmap` 与 `Superseded by` 表达的是两种不同关闭语义，不应作为对称默认字段同时预填。

## 时间戳规范

- MUST: `Last updated`、`Completed at`、`Superseded at` 等字段都必须包含日期、时间和时区。
- MUST: 默认使用 ISO 8601，例如 `2026-04-15T14:32:00+08:00`。
- MUST NOT: 不得只写日期，例如 `2026-04-15`。
- MUST NOT: 不得使用 `today`、`yesterday`、`just now` 这类相对时间。
- SHOULD: `index.md` 的 `Last updated` 与单份 roadmap 使用同一时间格式。

## 判定口径

- MUST: 若路线仍成立，只是进度推进不完整，更新原 roadmap。
- MUST: 若问题定义已经变化、关键假设已经失效，或路线被新方案接管，创建新 roadmap 并更新旧 roadmap 状态。
- SHOULD: 若只是新增执行反馈、风险或阶段进展，不要因为“又有新内容”就新建一份 roadmap。
- SHOULD: 新建 roadmap 默认按 `active` 或 `draft` 的活文档结构开始，不要预填关闭态字段。
- SHOULD: 旧 roadmap 只有在变为 `completed` 或 `superseded` 时，再追加收口字段。
