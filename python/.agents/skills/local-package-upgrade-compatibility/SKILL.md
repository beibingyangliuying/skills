---
name: local-package-upgrade-compatibility
description: 当任务涉及将当前项目附近的本地 `.whl` / `.tar.gz` 升级到更高版本时使用，负责盘点 breaking changes 与迁移动作，不用于一般性的本地包接入选择。
---

# Local Package Upgrade Compatibility

## 核心目标

在升级本地包到新版本时，系统识别受影响边界、实施必要改造，并清楚说明影响与迁移方式。

## 边界说明

- MUST: 本 skill 处理的是“依赖本地包升级带来的改造”，不是“当前仓库本身作为发布包时的兼容性保护”。
- SHOULD: 若任务重点是复用本地包现有能力而不是升级版本，优先使用 `local-package-integration`。
- SHOULD: 若任务重点是保护当前仓库作为对外发布包的兼容性，优先使用 `published-package-compatibility`。

## 主流程

### 1. 升级前识别

- MUST: 明确区分升级前正在使用的旧版本候选与准备对齐的新版本候选。
- MUST: 若未找到足够证据判断目标版本，不要假装升级目标已明确；应说明缺失的是文件、版本还是调用线索。
- SEE: 需要候选识别与影响盘点细则时，读取 `references/upgrade-impact-audit.md`。

### 2. 受影响边界盘点

- MUST: 在修改前先盘点受影响边界，包括 import 路径、导出符号、函数签名、返回结构、异常语义、配置、CLI、序列化字段与适配层。
- SHOULD: 将“需要直接替换的调用点”和“可以通过局部适配吸收的差异”分开描述。

### 3. 升级策略

- MUST: 以对齐新版本接口与行为为优先目标。
- MUST: 若为了对齐已明确的新版本而必须接受 breaking change，明确说明影响面、迁移路径与最小验证项。
- SEE: 需要迁移策略、breaking change 汇报和最小验证项时，读取 `references/migration-path.md`。

### 4. 结果汇报

- MUST: 明确说明升级前后涉及的包名与版本。
- MUST: 明确列出识别到的 breaking changes。
- MUST: 明确说明当前项目中受影响的调用点或边界类型。
- MUST: 明确说明需要的适配、替换或删除动作。
- MUST: 提供推荐迁移路径与最小验证项。

## 交付检查清单

在完成任务前，检查：

- 是否已识别旧版与新版本地包候选
- 是否已盘点 import、导出、签名、返回结构、异常、配置、CLI 与序列化字段影响
- 是否已明确哪些 breaking change 是升级所必需的
- 是否已说明需要的适配、替换或删除动作
- 是否已提供迁移路径与最小验证项
