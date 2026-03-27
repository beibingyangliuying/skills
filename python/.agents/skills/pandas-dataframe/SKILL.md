---
name: pandas-dataframe
description: 当任务涉及本仓库中的 pandas DataFrame 或 Series 数据处理时使用，用于约束结构说明、转换可读性和结果稳定性，不用于绘图导出或一般性的仓库工作流问题。
---

# Pandas DataFrame

## 核心目标

写出可读、可验证、约束清晰的数据处理代码，避免隐式假设与脆弱转换。

## 边界说明

- MUST: 本 skill 只聚焦 DataFrame/Series 数据处理行为，不替代绘图、仓库环境或发布兼容性规范。
- SHOULD: 若任务重点是出图与导出，优先使用 `matplotlib-figures`；若重点是通用 Python 接口整理，优先遵循 `AGENTS.md` 与其他通用 skill。

## 主流程

### 1. 结构约束必须显式

- MUST: 若函数输入或输出为 DataFrame/Series，文档中必须说明关键结构约束。
- SEE: 需要输入输出结构、列约束和结果表达细则时，读取 `references/structure-contracts.md`。

### 2. 写法选择

- SHOULD: 在可读性良好的前提下优先采用链式操作。
- MUST: 不要为了追求“链式”而牺牲可读性。
- SEE: 需要链式拆分、reshape/merge 风险和结果稳定性细则时，读取 `references/transformation-safety.md`。

### 3. 数据安全与稳健性

- MUST: 对可能依赖列存在性的逻辑保持谨慎，不默认假设列一定存在，除非上游约束已明确。

## 交付检查清单

在完成代码前，检查：

- 文档是否写明所需列与结果结构
- 链式操作是否仍然可读
- 是否存在隐式依赖列名或索引的逻辑
- 结果粒度是否清晰
- 是否引入了不必要的中间副作用
