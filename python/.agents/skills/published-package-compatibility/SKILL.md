---
name: published-package-compatibility
description: 当任务涉及当前仓库作为对外发布 Python 包的公开接口、发布配置或兼容性边界时使用，负责优先保护现有用户升级体验，不用于本地包候选识别或外部依赖升级改造。
---

# Published Package Compatibility

## 核心目标

在识别到当前仓库很可能是对外发布的 Python 包时，默认优先保护现有用户的升级体验，避免无说明的破坏性变更。

## 边界说明

- MUST: 本 skill 限定为“当前仓库本身作为对外发布包”的兼容性保护规则。
- MUST: 不要把“识别根目录本地包发布产物”的逻辑重新塞回本 skill。
- SHOULD: 若任务重点是升级项目附近的本地 `.whl` / `.tar.gz` 并改造适配，优先使用 `local-package-upgrade-compatibility`。
- SHOULD: 若任务重点只是评估或接入本地包能力，优先使用 `local-package-discovery` 或 `local-package-integration`。

## 主流程

### 1. 识别规则

- MUST: 在修改公开接口、目录结构、依赖、CLI、配置或文件格式前，先判断当前项目是否属于对外发布的包。
- MUST: 不要仅因根目录存在 `dist/` 或单个构建产物，就直接认定当前项目是对外发布包。
- SEE: 需要强信号、辅助信号和切换条件时，读取 `references/package-signals.md`。

### 2. 兼容性优先级

- MUST: 默认优先保持公共 import 路径、模块导出、函数签名、参数语义、返回结构与异常行为稳定。
- MUST: 默认优先保持 CLI 参数、子命令、退出码语义与帮助信息中的关键用法稳定。
- MUST: 默认优先保持配置 key、配置文件结构、序列化字段、文件格式与默认行为稳定。
- MUST: 不要在未明确告知用户的情况下引入破坏性重命名、删除、重排、收紧类型约束或改变默认值语义。
- SEE: 需要兼容面优先级和具体实施策略时，读取 `references/compatibility-surface.md`。

### 3. 实施策略

- SHOULD: 优先做增量兼容修改，而不是直接替换旧接口。

### 4. 验证要求

- MUST: 修改前先识别哪些符号、导出模块、命令、配置项或文件格式已经对外暴露。
- MUST: 若存在潜在 breaking change，必须在结果汇报中明确指出影响面、迁移方式与是否已有兼容层。
- SEE: 需要验证范围与结果汇报细则时，读取 `references/migration-reporting.md`。

### 5. 结果汇报

- MUST: 明确说明识别到了哪些“对外发布包”信号。
- MUST: 明确说明本次修改影响了哪些公开接口边界。
- MUST: 若保留了兼容层、旧别名或过渡方案，必须说明保留方式。
- MUST: 若无法避免破坏性变化，必须明确提示用户，而不是默认替用户接受 breaking change。

## 交付检查清单

在完成任务前，检查：

- 是否已识别到足以进入兼容性优先模式的发布信号
- 是否已盘点公共接口边界
- 是否避免了不必要的 breaking change
- 是否为兼容层、旧行为或过渡路径保留了验证
- 是否检查了 README、示例、测试或导出入口的一致性
- 是否在无法避免破坏时明确提示用户
