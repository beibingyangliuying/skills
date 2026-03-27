# Execution And Parallel

## Execution Plan

- MUST: 真正运行实验前，先展示 execution plan，并等待用户确认。
- MUST: execution plan 至少覆盖实验目标、case 规模或参数展开摘要、执行方式、输出位置、预计产物和失败处理方式。
- SHOULD: 当配置来自 `experiments/*.toml` 时，在 plan 中明确指出配置来源。
- SHOULD: 当任务是继续一个被中断的实验时，在 plan 中明确说明这是续跑已有 run，并概括已完成、未完成和失败 case 的处理方式。
- SHOULD: 当参数展开很多时，先给总量和关键维度摘要，不必逐项铺开所有细节。

## 进度展示

- SHOULD: 长时间运行的实验使用 `tqdm` 或等价进度条，至少让用户看到总体进度。
- SHOULD: 若存在天然的两层进度，例如“总 case 数”和“单 case 内部迭代”，优先展示最能帮助判断剩余时间的一层。
- MUST: 不要在高频循环里输出嘈杂日志来代替进度展示。

## 并行建议

- SHOULD: 当 case 独立、计算偏 CPU-bound 且数量较多时，优先考虑多进程。
- SHOULD: 当任务很小、依赖共享可变状态、或启动开销明显高于收益时，保持串行。
- SHOULD: 在本地单机 CPU 场景下，优先选简单稳定的并行方式，不为 v1 额外引入复杂调度层。
- SHOULD: 在 Windows 下按多进程约束组织代码，例如让 worker 逻辑可被子进程稳定导入，并避免把关键执行逻辑埋在只适合主进程调用的局部作用域里。

## 断点续跑

- MUST: 支持 case 粒度的断点续跑，避免实验中断后只能从头开始。
- SHOULD: 默认跳过已完成 case，继续未完成 case。
- SHOULD: 已失败 case 默认保留失败状态，不自动重跑，除非任务明确要求重试失败 case。
- SHOULD: 若配置或 case 集合发生实质变化，优先新开 run，而不是静默复用旧 run。
- SHOULD: 续跑判断优先依赖稳定的 case 标识和 manifest 中的状态记录。

## 失败处理

- MUST: 对失败 case 保留状态与错误摘要，不静默丢弃。
- SHOULD: 默认优先继续收集其他 case 的结果，除非任务明确要求 fail-fast。
- SHOULD: 在 summary 中体现成功/失败计数，并让后续任务能定位失败记录。
