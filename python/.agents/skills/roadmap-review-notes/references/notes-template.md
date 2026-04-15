# Notes Template

## 目标

把 roadmap 输入型评审备注写得足够清晰、足够轻，并让后续的人或 AI 能直接判断哪些内容值得进入 roadmap。

## Concern 写法

- MUST: 每条 main concern 都同时说明三件事：观察到的现象、为什么它值得进入后续路线讨论、可以朝什么方向收敛。
- MUST: 只在证据已经足够时，把某个判断写成 main concern。
- SHOULD: 单条 concern 以“小标题 + 2~4 句说明”为主，不必写成表格。
- SHOULD: 优先使用具体代码依据，例如模块关系、依赖流向、状态入口、配置方式、接口边界或测试组织。

## Watchlist 边界

- MUST: 若证据不足、问题尚未稳定出现、或只是值得后续改动时继续观察的信号，将其写入 `Watchlist`。
- MUST NOT: 不得把个人风格偏好、未验证猜测或轻微信号包装成 roadmap 输入。
- SHOULD: `Watchlist` 只保留少量高价值观察项，不堆积“可能以后再看”的泛泛提醒。

## 推荐模板

```md
# Roadmap review notes

Review time: <2026-04-15T14:32:00+08:00>

## Context
- Scope: <本次评审范围>
- Why this review was done: <为什么会做这次评审>

## Main concerns

### <问题标题>
<观察到的现象。>
<为什么它后续可能成为问题。>
<后续可考虑的收敛方向。>

### <问题标题>
<观察到的现象。>
<为什么它后续可能成为问题。>
<后续可考虑的收敛方向。>

## Roadmap implications
- <哪些问题已经足以进入后续路线讨论>
- <哪些问题会影响阶段拆分、优先级或实施顺序>

## Watchlist
- <现在还不构成问题，但后续值得继续留意的点>

## Not in scope
- <本次没有检查的部分>
```
