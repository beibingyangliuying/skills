# Python Skills Governance Roadmap

Status: active
Scope: python/.agents/skills
Last updated: 2026-04-15T16:13:55+08:00

## Context

当前仓库已经形成一组相对完整的 Python skills，并且大部分 skill 已经具备清晰的 `SKILL.md` / `references/` 分层结构。最近一次横向检查表明，整体职责边界基本健康，但仍存在少数会持续放大维护成本的问题，主要集中在 roadmap 字段 schema 一致性、模板重复、执行型 workflow 规则过严，以及个别组织性约束的默认强度偏高。

由于 `doc/roadmaps/` 目前刚建立，现阶段先维护单份 roadmap，自身承担完整上下文说明；暂不额外创建 `index.md`，以避免在主题仍单一时过早引入全局索引负担。

## Goal

把 `python/.agents/skills` 整理成一套更稳定、更一致、后续更容易扩展的 skill 系统：

- roadmap 相关 skill 的字段、模板和生命周期口径保持一致。
- 各 skill 的主文档与 reference 分工更清楚，减少重复事实来源。
- 执行型 skill 在保持安全边界的同时，降低不必要的工作流摩擦。
- 组织型建议保持“有帮助但不过度侵入”，减少对目标仓库的额外结构噪音。

## In scope

- 统一 `roadmap-lifecycle` 中关闭态字段与模板命名。
- 收敛 `roadmap-review-notes` 中重复模板，保证单一事实来源。
- 对超长 reference 做轻量 authoring 整理，例如目录、导航或压缩重复说明。

## Out of scope

- 一次性重写所有现有 skill 的措辞风格。
- 新增大批全新 skill，或在本次整理中扩大 skill 体系范围。
- 改造与本次评审无关的仓库级 AGENTS 规则。
- `repo-workflow` 的环境确认策略调整，以及 `python-code-organization` 中 `region` 强度校准；这两项属于 Phase 3，本轮明确 `deferred`。
- 为目前仍是单主题场景的 `doc/roadmaps/` 提前引入复杂 index / archive 体系。

## Current state

- 已完成一轮对 `python/.agents/skills` 的横向审阅。
- 已确认没有明显的“硬冲突”导致 skill 无法共存。
- 已确认若不做整理，最可能持续产生维护成本的是以下四类问题：
  - `roadmap-lifecycle` 内部字段 schema 不完全统一。
  - `roadmap-review-notes` 在 `SKILL.md` 与 `references/` 之间存在模板重复。
  - `repo-workflow` 的环境确认门槛偏高，容易卡住执行型任务。
  - `python-code-organization` 对 `region` 的默认要求偏强。

## Plan

### Phase 1: 收敛 roadmap 相关 schema

- 统一 `roadmap-lifecycle` 中关闭态字段的命名与模板。
- 以 `state-and-timestamps.md` 为主字段字典，清理 `structure-and-templates.md` 中偏离字段。
- 保证新建 roadmap、completed/superseded 收口、archive 模板三者口径一致。

### Phase 2: 减少重复事实来源

- 将 `roadmap-review-notes` 的模板事实收敛到 `references/notes-template.md`。
- 让 `SKILL.md` 只保留目标、边界、流程和必要摘要，通过 `SEE:` 指向模板细则。
- 顺手检查其他 skill 是否存在相同模式的重复定义，但只处理明显重复项。

### Phase 3: 调整执行与组织类规则强度 [deferred]

- 本轮不处理 `repo-workflow` 的环境确认流程。
- 本轮不处理 `python-code-organization` 中 `region` 的默认强度。
- 待 Phase 1、2、4 收敛后，再单独决定是否恢复这一 phase。

### Phase 4: 轻量 authoring 整理

- 为明显偏长的 reference 文件补简短目录或预览导航。
- 清理可压缩的重复描述，但不改变原有 MUST / SHOULD 语义强度。
- 保持 `README.md` 中的 authoring guide 与实际目录实践一致。

## Progress update

- 2026-04-15T15:45:58+08:00: 已完成首轮 skill 审阅，并整理出优先级较高的治理项。
- 2026-04-15T15:45:58+08:00: 已建立 `doc/roadmaps/`，并将本次整理目标收敛为单份活跃 roadmap。
- 2026-04-15T16:07:23+08:00: 本轮实施范围已锁定为 Phase 1、Phase 2、Phase 4；Phase 3 明确标记为 `deferred`。
- 2026-04-15T16:13:55+08:00: 已补齐 `Progress update` 的时间戳约束，使其与 roadmap 的时间字段规范保持一致。

## Open questions

- 当前无阻塞性 open questions。
- 若 Phase 1 完成后还要继续扩展到其他 roadmap 输出示例，再单独决定是否开启下一轮整理。

## Risks / watchlist

- 若在整理中顺手优化措辞过多，容易让本次治理从“统一结构”膨胀成“全面重写”。
- 若只改模板、不改边界说明，后续仍可能出现新旧 schema 混用。
- 若 `repo-workflow` 放松过头，可能削弱原本想保护的环境安全边界。
- 若 `doc/roadmaps/` 很快出现多份 roadmap，需要及时补 `index.md`，避免后续再次混淆当前有效路线。
