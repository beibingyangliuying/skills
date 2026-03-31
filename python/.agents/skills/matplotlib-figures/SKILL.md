---
name: matplotlib-figures
description: 当任务涉及本仓库中的 Matplotlib 绘图、版式调整或图像导出时使用，用于保证图形可读性与导出稳定性，不用于与 Matplotlib 无关的数据建模或前端图表任务。
---

# Matplotlib Figures

## 核心目标

输出版式稳定、标签清晰、适合科研使用的图形结果，并尽量保持与仓库既有图形风格一致。

## 边界说明

- MUST: 本 skill 只约束 Matplotlib 绘图与导出相关工作，不替代通用数据处理或接口设计规范。
- SHOULD: 若任务重点是 DataFrame/Series 处理而不是出图，优先使用 `pandas-dataframe`；若主要是一般 Python 结构重构，优先遵循 `AGENTS.md` 与其他通用 skill。

## 主流程

### 1. 运行环境

- MUST: 当需要由 AI 自己在终端直接运行 Matplotlib 绘图命令时，在 PowerShell 命令前先设置 `$env:MPLBACKEND='Agg';`，再执行 Python 命令或脚本，以避免 TkAgg 等交互式后端在无图形环境中报错。
- SHOULD: 终端命令优先写成 `$env:MPLBACKEND='Agg'; <原命令>` 的形式。

### 2. 布局与导出

- SHOULD: 在保存或显示图像前，优先处理布局问题。
- SHOULD: 导出时优先选择与仓库既有产出规范一致的格式与参数。
- SEE: 需要布局处理与导出细则时，读取 `references/layout-and-export.md`。

### 3. 图形可读性

- MUST: 轴标签、标题、图例、刻度应可读且语义明确。
- SHOULD: 尽量避免标签重叠、图例遮挡、边距裁切。
- SHOULD: 修改绘图逻辑时优先保持既有配色、线型与视觉语义，除非任务明确要求调整。

### 4. 数据留存与代码组织

- MUST: 若任务明确要求科研复现、报告资产沉淀、批量出图流程，或仓库已有同类约定，导出图像时同时保留可复现绘图输入。
- SEE: 需要 `plot_data/` 约定、格式选择或代码组织细则时，读取 `references/plot-data-retention.md`。

## 交付检查清单

在完成代码前，检查：

- 若由终端直接执行绘图命令，是否已先设置 `$env:MPLBACKEND='Agg';`
- 布局是否稳定
- 保存参数是否符合任务或仓库要求
- 标签与图例是否清晰
- 是否破坏了既有图形风格
- 导出格式是否与使用场景一致
- 若任务需要保留绘图输入，是否同步保留了原始数据
- 若保留原始数据，是否优先使用 `plot_data/` 目录和合适的持久化格式
