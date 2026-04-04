---
name: numerical-experiments
description: 当任务涉及数值实验设计、批量运行、本地 CPU 多进程、execution plan、断点续跑或实验产物留存时使用，负责实验 orchestration、结果留存和 plot handoff，不替代具体的数据处理或绘图规范。
---

# Numerical Experiments

## 核心目标

用尽量轻量的约定组织数值实验，让实验在运行前可确认、运行中可追踪、结束后可定位、被中断后可继续，并为后续分析与绘图保留足够的数据和元信息。

## 边界说明

- MUST: 本 skill 负责实验 orchestration、execution plan、结果留存、断点续跑和 plot handoff。
- MUST: 本 skill 不替代 `matplotlib-figures` 的具体绘图规范。
- MUST: 本 skill 不替代 `pandas-dataframe` 的数据整理与表格处理规范。
- SHOULD: 若任务同时包含实验运行与出图，先用本 skill 固定实验配置、运行目录和 plot handoff，再联合使用 `matplotlib-figures` 完成绘图细节。
- SHOULD: 若任务重点是整理 DataFrame、聚合结果表或清洗实验结果，再联合使用 `pandas-dataframe`。

## 主流程

### 1. 固定实验入口

- MUST: 对可复用实验，优先将实验定义整理到 `experiments/*.toml`。
- MUST: 将 `experiments/*.toml` 视为可复用实验配置的固定放置位置。
- SHOULD: TOML 字段按需设计，只要能清楚表达实验需求、运行入口、参数组织和输出位置即可。
- SHOULD: 当需求还不稳定时，可以先从最小配置起步，再逐步收敛到可复用的 TOML。
- SEE: 需要约定 TOML 的职责和组织方式时，读取 `references/toml-schema.md`。

### 2. 运行前先给计划

- MUST: 真正执行实验前，先生成并展示 execution plan，等待用户确认后再运行。
- MUST: execution plan 至少说明本次实验准备跑什么、预计有多少 case 或参数组合、是否并行、输出位置、预计产物和失败处理方式。
- SHOULD: 若用户要继续一个被中断的实验，在 plan 中说明这是续跑已有 run，以及已完成和待继续的 case。
- SHOULD: 当实验规模较大时，先对参数展开和输出目录做简要摘要。
- SHOULD: 若用户要求直接执行，也先给 plan，再继续。

### 3. 运行时保持可追踪

- SHOULD: 对长时间运行的实验提供清晰的进度展示，优先使用 `tqdm` 或同类进度条。
- SHOULD: 当任务适合本地 CPU 并行时，优先考虑多进程。
- MUST: 不适合并行时，不要机械并行化。
- MUST: 支持 case 粒度的断点续跑，避免实验被中断后只能从头开始。
- SHOULD: 续跑时默认跳过已完成 case，继续未完成 case。
- SHOULD: 已失败 case 默认保留失败记录，不自动重跑，除非任务明确要求重试失败 case。
- SHOULD: 对失败 case 保留状态和错误摘要，不静默忽略。
- SEE: 需要并行实现注意事项、进度展示建议或失败处理约定时，读取 `references/execution-and-parallel.md`。

### 4. 运行后保留可复用产物

- SHOULD: 默认将实验结果组织到 `artifacts/experiments/<experiment_name>/<run_id>/`，若项目已有约定则优先贴合项目现状。
- MUST: 每次运行至少保留 `run_manifest.json` 和 `summary.json`。
- MUST: `run_manifest.json` 应记录本次 run 的基本信息、配置来源或摘要、case 组织方式、主要输出位置、失败记录入口和 case 状态。
- MUST: `summary.json` 应记录总体状态、成功/失败计数、关键结果摘要和剩余工作量摘要。
- MUST: 不要只保留最终图片或零散结果文件；要保留后续分析或绘图真正需要的数据与元信息。
- SEE: 需要默认目录结构、元数据职责或结果格式建议时，读取 `references/artifact-layout.md`。

### 5. 为后续绘图做 handoff

- SHOULD: 当实验明显是为后续绘图服务时，在 run 目录中优先使用 `plots/` 保存图像输出，使用 `plot_data/` 保存绘图输入数据。
- SHOULD: 若本次尚未出图，也要让后续任务能从 run 目录中定位对应数据和结果摘要。
- MUST: plotting handoff 的目标是让后续绘图任务先找到 run，再找到数据和元信息，而不是倒推图片来源。

## 交付检查清单

在完成相关任务前，检查：

- 可复用实验是否已整理到 `experiments/*.toml`
- 是否在运行前先展示了 execution plan
- 是否为长时间任务提供了清晰进度，并根据场景合理选择了串行或多进程
- 若实验被中断，后续是否能按 case 粒度继续
- 是否至少保留了 `run_manifest.json` 和 `summary.json`
- 是否保留了后续分析或绘图真正需要的数据与元信息
- 若任务涉及绘图衔接，后续是否能从 run 目录直接定位到对应数据
