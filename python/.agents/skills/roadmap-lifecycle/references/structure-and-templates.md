# Structure And Templates

## 目标

为单份 roadmap、全局 index 和 archive 收口提供一套轻量、稳定、易读的默认结构。

## 推荐目录结构

当 roadmap 数量较多、状态混杂或关系变复杂时，优先采用类似结构：

```text
docs/
  roadmaps/
    index.md
    active/
      payment-retry-roadmap.md
    drafts/
      cache-exploration-roadmap.md
    archive/
      completed/
        auth-cleanup-roadmap.md
      superseded/
        old-worker-roadmap.md
```

当 roadmap 仍然很少、关系简单时，可以先只维护各文档自身头部信息，暂不创建 `index.md`。

## Active / Draft Roadmap 模板

```md
# Payment Retry Roadmap

Status: active
Scope: payment retry flow
Last updated: 2026-04-15T14:32:00+08:00
Related roadmaps: plugin-runtime-roadmap.md

## Context
为什么会有这份 roadmap。

## Goal
这份 roadmap 想达成的结果。

## In scope
这份 roadmap 负责解决什么。

## Out of scope
这份 roadmap 不负责什么。

## Current state
当前推进到哪里，存在哪些关键约束。

## Plan
按阶段或里程碑描述路线。

## Progress update
记录执行后的新进展、部分完成项和判断变化。

## Open questions
还没定的关键问题。

## Risks / watchlist
继续推进时需要盯住的风险或观察项。
```

新建 roadmap 默认从这类活文档模板开始。不要为新 roadmap 预填 `Superseded by`、`Next roadmap`、`Final note` 等关闭态字段；只有在关系已经真实存在时才追加相关字段。

## Completed / Superseded 收口补丁模板

当 roadmap 进入 `completed` 或 `superseded` 状态时，在原文基础上追加收口字段，而不是回到新模板里预留占位值。

### Completed 补丁

```md
Status: completed
Last updated: 2026-04-15T18:05:00+08:00
Completed at: 2026-04-15T18:05:00+08:00
Next roadmap: payment-hardening-roadmap.md

## Final note
Why it stopped: 主体目标已完成。
Completion level: 主体完成，剩余优化项转入后续路线。
```

### Superseded 补丁

```md
Status: superseded
Last updated: 2026-04-15T18:05:00+08:00
Superseded at: 2026-04-15T18:05:00+08:00
Superseded by: async-runtime-roadmap.md

## Final note
Why it stopped: 原路线已被新方案替代。
Completion level: 部分完成后切换路线。
```

“继续推进原路线”不自动生成 successor 字段；只有确实形成后继路线时才写 `Next roadmap` 或 `Follow-up`。

## Index 模板

```md
# Roadmap Index

Last updated: 2026-04-15T14:32:00+08:00

## Active
- `active/payment-retry-roadmap.md`
  Scope: payment retry flow
  Note: 当前执行中的专题路线

## Draft
- `drafts/cache-exploration-roadmap.md`
  Scope: cache invalidation exploration
  Note: 仍在探索，不作为当前执行依据

## Completed
- `archive/completed/auth-cleanup-roadmap.md`
  Final note: 认证清理主体已完成

## Superseded
- `archive/superseded/old-worker-roadmap.md`
  Superseded by: `active/async-runtime-roadmap.md`
  Final note: 原路线已被新方案替代
```

`Current focus` 不作为默认块；只有在需要给他人或无人指定时的 AI 提供明确入口，且多份 `active` 的优先级容易混淆时，才作为可选结构增加。

## Archive 收口模板

```md
## Final note
Roadmap status closed at: 2026-04-15T18:05:00+08:00
Why it stopped: <已完成 / 被替代 / 前提失效>
Completion level: <主体完成 / 部分完成 / 探索结束未继续采用>
Follow-up: <下一份 roadmap 或无>
```
