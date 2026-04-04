---
name: repo-workflow
description: 当任务涉及仓库环境确认、Python 命令执行、脚本运行或 `pytest` 验证时使用，负责保证命令在正确环境中执行，不用于代码风格或接口设计约束。
---

# Repo Workflow

## 核心目标

在正确的仓库环境中执行命令，并以最小代价验证修改结果。

## 边界说明

- MUST: 本 skill 只约束环境确认、命令执行与验证流程，不替代其他专项规则。
- SHOULD: 若任务只是静态改写代码而不需要运行命令，本 skill 可以只提供最小化的验证判断，不必强行扩展工作流步骤。

## 主流程

### 1. 环境确认

- MUST: 在运行本仓库相关 Python 命令前，先查看仓库已有的环境约定。
- MUST: 若仓库未明确给出虚拟环境激活方式，必须暂停后续 Python 命令、脚本运行与验证工作，并向用户询问应如何激活环境或应使用哪个入口。
- MUST NOT: 不得在缺少仓库依据时，自行尝试猜测式的虚拟环境激活方式或临时发明执行入口。
- SHOULD: 若虚拟环境已经成功激活，运行脚本、模块与测试时优先使用当前 shell 中可直接执行的 Python 命令，例如 `python -m pytest`、`python -m package.module` 或 `python script.py`。
- MUST: 只有当任务本身属于依赖安装、环境同步、锁文件维护或其他环境管理操作时，才改为参考 `references/uv-active-rules.md` 中的规则执行。
- MUST NOT: 涉及虚拟环境配置、依赖安装、环境同步或解释器环境变更时，不得使用 `pip`。
- SEE: 需要环境选择顺序时，读取 `references/environment-selection.md`。
- SEE: 需要 `uv --active` 的完整约束时，读取 `references/uv-active-rules.md`。

### 2. 测试执行

- MUST: 默认使用 `pytest`。
- SHOULD: 若虚拟环境已经成功激活，优先使用当前 shell 中的 Python 命令运行测试，例如 `python -m pytest`，不要默认切到 `uv` 入口。
- SHOULD: 修改公开函数、核心逻辑、数据处理流程或 bug 修复后，优先运行最相关的最小测试集。
- SEE: 需要测试范围、doctest 边界或命令验证细则时，读取 `references/verification-scope.md`。

### 3. 脚本与命令验证

- SHOULD: 先做最小可验证修改，再运行最小必要命令验证。
- SHOULD: 脚本运行与命令验证优先沿用已激活环境中的 shell Python 命令；`uv` 只用于仓库约定或任务本身要求的环境管理操作。
- MUST: 不要假装命令已经成功运行；只报告实际执行和实际结果。
- MUST: 若未运行测试或命令验证，必须明确说明原因。

## 交付检查清单

在完成任务前，检查：

- 是否已先查看仓库现有环境约定
- 若未找到明确激活方式，是否已暂停执行并向用户询问，而不是继续猜测环境入口
- 跑代码、跑模块或跑测试时，是否优先使用了已激活环境下的 shell Python 命令
- 涉及环境或依赖变更时，是否避免使用 `pip`，并在必须使用 `uv` 时遵循了 `uv-active-rules`
- 若已激活环境，是否为所有实际执行的 `uv` 命令附加了 `--active`
- 是否运行了相关 `pytest`
- 是否如实汇报了未执行测试的原因
- 是否避免把一般代码改写错误地扩展成工作流任务
