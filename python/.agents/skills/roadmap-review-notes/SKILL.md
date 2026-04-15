---
name: roadmap-review-notes
description: 当任务涉及评估某个模块、方案、子系统或实现方向是否值得进入 roadmap，或希望把不适合立即修改、但值得纳入后续路线决策的问题整理为轻量 Markdown 备注时使用，负责生成 roadmap 输入型评审留档，不替代正式 roadmap 编写、实施任务、bug 修复或一般性代码风格审查。
---
# Roadmap Review Notes

## 核心目标

把评审中那些“现在不一定立刻修改、但后续很可能影响路线选择、阶段拆分、优先级或实施顺序”的问题，整理成一份轻量、可回看、可继续接上的 Markdown 备注，为后续 roadmap 提供输入材料，而不是让这些判断只停留在当前上下文里。

## 边界说明

- MUST: 本 skill 只负责生成 roadmap 输入型评审备注，不替代 `roadmap-lifecycle`、`repo-workflow`、`python-code-style`、`dead-code-cleanup`、`python-test-organization` 等专项 skill。
- MUST: 本 skill 的默认目标是记录后续路线 concern，而不是立即修改代码；除非用户明确要求，不要把评审自动扩展为重构、修复或实施任务。
- MUST: 仅记录会影响后续路线选择、阶段拆分、优先级、模块边界、依赖方向或实施顺序的问题，不记录局部格式、命名、import 顺序等轻量实现噪音。
- MUST: 输出是 review notes，而不是正式 roadmap；不要把尚未收敛的问题直接写成带承诺感的实施计划。
- MUST NOT: 不得为了显得“全面”而机械罗列泛泛的架构套话，例如“耦合较高”“扩展性不足”“建议分层”，除非这些结论有明确代码依据。
- MUST NOT: 不得把未经证实的猜测、个人风格偏好或弱信号包装成确定性路线问题。
- SHOULD: 若任务重点已经变成“整理 roadmap 状态”“判断是否应归档”“维护 index”，切换到 `roadmap-lifecycle`，而不是继续用本 skill 承载生命周期治理。
- SHOULD: 若评审结果中包含长期有效、会反复影响后续决策的仓库隐式约定，可再按需衔接 `local-memory-capture`；但不要把 roadmap 备注和本地记忆机械合并。
- SEE: 需要 concern 写法、watchlist 边界或输出模板时，读取 `references/notes-template.md`。

## 主流程

### 1. 先确认任务是否属于“roadmap 输入型评审备注”

- MUST: 只有当用户明确希望评估某个方向是否值得进入 roadmap、沉淀后续路线 concern、形成评审备注或保留值得继续观察的设计问题时，才使用本 skill。
- MUST: 若任务只是一般 code review、bug 排查、测试修复、样式整理或正式写 roadmap，不要误触发本 skill。
- SHOULD: 当用户表达类似“先不用改”“先记下来”“看看哪些问题值得纳入后续路线”“先做成 roadmap 输入”时，优先按本 skill 处理。

### 2. 先限定评审范围

- MUST: 在输出备注前，先明确本次评审针对的范围，例如某个模块、某条调用链、某个子系统、某类抽象边界，或某个待讨论的方案方向。
- MUST: 若实际只看了局部代码，不要把结论表述成覆盖整个项目的全面判断。
- SHOULD: 在备注开头简要说明本次评审的背景、范围和为什么会做这次评审，避免后续回看时失去上下文。

### 3. 只记录对 roadmap 有价值的 concern

- MUST: 每条 concern 都应同时回答三个问题：
  - 观察到了什么现象
  - 为什么这件事后续可能会成为问题
  - 后续可以朝什么方向收敛
- MUST: 每条 concern 都要基于实际代码结构、模块关系、依赖流向、状态组织、配置方式、接口边界或测试组织给出依据。
- MUST: 每条 main concern 都应能解释“为什么它值得进入后续路线讨论”，而不是只说明它现在看起来不舒服。
- MUST: 若某条判断暂时证据不足，应明确写成 `Watchlist`，而不是上升为确定性路线问题。
- SHOULD: 优先记录以下几类问题：
  - 模块职责混杂或边界漂移
  - 依赖方向不自然或跨层直接耦合
  - 抽象泄漏，导致上层感知过多底层细节
  - 配置、状态或数据流入口扩散
  - 扩展点不稳定，后续新增能力时可能频繁改动旧代码
  - 设计选择已经开始影响测试边界、替换成本或演进难度
- SHOULD: 不必追求数量；宁可只记录 2–4 条真正重要的 concern，也不要堆一长串轻飘问题。

### 4. 生成轻量 Markdown 备注

- MUST: 输出应为轻量 Markdown 备注，而不是正式 issue 列表、风险台账系统或字段过重的审计报告。
- MUST: 默认使用叙述式结构，让人能快速读懂，不要求每条都附带编号、负责人、截止时间或优先级。
- MUST: 至少区分 `Main concerns`、`Roadmap implications` 和 `Watchlist`。
- SHOULD: 备注开头在标题后补一行“Review time: <ISO 8601 时间戳>”，用于保留这次判断的时间上下文。
- SHOULD: 备注结构尽量简洁，默认包含：
  - `Context`
  - `Main concerns`
  - `Roadmap implications`
  - `Watchlist`
  - `Not in scope`
- SHOULD: 单条 concern 优先使用“小标题 + 2~4 句说明”的轻量写法，而不是表格。
- SHOULD: 完整模板、标题顺序和示例写法以 `references/notes-template.md` 为准；本文件只保留结构约束，不重复完整模板正文。

## 交付检查清单

在完成任务前，检查：

- 是否确认当前任务属于“roadmap 输入型评审备注”而不是正式 roadmap 编写
- 是否明确说明了本次评审范围，避免把局部观察写成全局判断
- 是否只保留了真正影响后续路线选择或实施顺序的 concern
- 是否把证据不足的判断下沉到了 `Watchlist`
- 是否明确写出了 `Roadmap implications`，说明哪些问题值得进入后续路线讨论
- 是否避免把输出写成 issue 系统、实施计划或重型模板
