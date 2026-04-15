---
name: roadmap-lifecycle
description: 当任务涉及识别当前仍有效的 roadmap、给 roadmap 补或更新状态信息、维护 roadmap index、对 completed 或 superseded 做收口与归档，或减少多份计划并存导致的上下文污染时使用，负责 roadmap 生命周期治理，不替代正式实施、bug 修复或一般性任务管理。
---

# Roadmap Lifecycle

## 核心目标

维护一套稳定、轻量、可被人和 AI 一起读懂的 roadmap 生命周期结构：单份 roadmap 自己能解释自己，多个 roadmap 并存时又能通过 index 看清当前状态、关系和历史收口。

## 边界说明

- MUST: 本 skill 只负责 roadmap 的状态治理、索引维护、收口与归档，不替代正式实施、bug 修复、代码重构或 issue 管理。
- MUST: 默认归档，不默认删除；只有明显低价值重复草稿、误生成文件或用户明确要求时，才考虑删除 roadmap 文件。
- MUST: 同时维护两层信息分工：
  - 单份 roadmap 负责局部元信息和自身上下文。
  - `index.md` 负责跨多份 roadmap 的全局导航、状态总览和关系视图。
- MUST NOT: 不得把所有状态和上下文都只塞进 index，导致单份 roadmap 脱离语境。
- MUST NOT: 不得把跨文档导航、主次关系和替代关系完全依赖单份 roadmap 自报，导致无法总览。
- SHOULD: 若任务重点是评估哪些问题值得进入路线讨论，优先使用 `roadmap-review-notes`，把本 skill 放在后续生命周期治理阶段。
- SEE: 需要状态字段、时间戳和判定口径时，读取 `references/state-and-timestamps.md`。
- SEE: 需要目录结构、单份 roadmap 模板、index 模板或 archive 收口模板时，读取 `references/structure-and-templates.md`。

## 主流程

### 1. 先判断当前是否需要 index

- MUST: 当 roadmap 数量很少、状态简单、关系清楚时，允许只维护单份 roadmap 自身的元信息，而不强制创建 index。
- MUST: 当出现以下任一情况时，引入或维护 `index.md`：
  - roadmap 数量开始变多
  - `active`、`draft`、`completed`、`superseded` 混在一起
  - 存在主次关系或替代链
  - AI 开始经常误读旧计划
- MUST: `index.md` 默认是全局状态索引，不是主 roadmap，也不是优先级控制台。
- MUST: `index.md` 默认不包含 `Current focus`；只有在需要为他人协作、无人指定时给 AI 预设入口、或多份 `active` 易混淆时，才作为可选块加入。

### 2. 维护单份 roadmap 的最小自解释信息

- MUST: 每份 roadmap 默认至少补齐以下头部字段：
  - `Status`
  - `Scope`
  - `Last updated`
- MUST: `Last updated` 必须包含日期、时间和时区；默认使用 ISO 8601，例如 `2026-04-15T14:32:00+08:00`。
- SHOULD: 仅在确有对应关系时补充状态特定字段，不要机械预填占位值：
  - `Related roadmaps` 用于真正相关的并行或关联文档
  - `Next roadmap` 仅用于已经明确存在后继路线时
  - `Superseded by` 仅用于已被替代的 roadmap
  - `Final note` 仅用于已收口的 roadmap
- MUST: 单份 roadmap 单独打开时，应能说明自己是谁、现在还是否有效、覆盖什么范围、推进到了哪里，以及是否已有后继或替代关系。
- MUST: 单份 roadmap 的唯一具体模板以 `references/structure-and-templates.md` 为准；本文件只保留规则、边界和判定口径。

### 3. 维护 index 的最小结构

- MUST: `index.md` 默认只保留以下结构：
  - `Last updated`
  - `## Active`
  - `## Draft`
  - `## Completed`
  - `## Superseded`
- MUST: 每条 index 条目只保留最少导航信息，例如 roadmap 路径、`Scope`、一句简短 `Note`，以及在需要时补 `Superseded by` 或 `Final note`。
- MUST NOT: 不得在 index 中重复 roadmap 的详细背景、阶段拆分、执行细节或风险说明。
- SHOULD: index 的主要职责是说明有哪些 roadmap、它们处于什么状态、彼此如何衔接，而不是替代单份 roadmap 本身。

### 4. 区分“继续更新原 roadmap”和“生成下一份 roadmap”

- MUST: 当目标未变、作用范围未变、原阶段划分仍成立，且当前只是部分完成或补充执行反馈时，继续更新原 roadmap。
- MUST: 当原路线的关键假设失效、剩余工作已经变成独立主题、需要切换到新路线、或原路线完成后自然引出下一阶段时，新建下一份 roadmap。
- MUST: 若只是续推，保留原 roadmap 为 `active`，并更新 `Last updated` 与 `Progress update`；不要因为新增反馈就预先生成 successor 字段。
- MUST: 若路线被替代，旧 roadmap 标记为 `superseded`，补 `Superseded at`、`Superseded by` 与 `Final note`。
- MUST: 若阶段完成但引出后续工作，旧 roadmap 标记为 `completed`，补 `Completed at` 与 `Final note`，并仅在后继路线已明确存在时写 `Next roadmap` 或 `Follow-up`。
- MUST: 当关系变化影响全局可见性时，同步更新 index。

### 5. 收口与归档

- MUST: 当 roadmap 已被替代、主体任务完成、前提失效、只是一次未延续的探索，或继续放在主视野只会干扰判断时，将其移出活跃视野并归档。
- MUST: 归档前在原文中写清 `Final note`，说明为什么结束、完成到什么程度、或为什么被替代。
- SHOULD: `completed` 与 `superseded` 可以分开归档，以保留更清晰的历史语义。
- SHOULD: 若某份 roadmap 只是早期探索且从未成为正式执行依据，可保留在 `draft` 体系；若已明显失效，再转入 archive。

## 交付检查清单

在完成任务前，检查：

- 是否先判断了当前复杂度是否真的需要 `index.md`
- 是否保证单份 roadmap 自身仍然可自解释，而不是把状态全推给 index
- 是否统一使用带日期、时间和时区的时间戳
- 是否把 `index.md` 保持为轻量导航，而不是再次写成主 roadmap
- 是否明确区分了“更新原 roadmap”与“生成下一份 roadmap”
- 是否在 completed 或 superseded 时补上了清晰的 `Final note`
- 是否默认采用归档而非删除，保留历史价值
