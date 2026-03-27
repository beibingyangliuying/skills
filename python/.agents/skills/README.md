# Python Skills Authoring Guide

本目录中的 Python skill 采用与 `numerical-experiments` 一致的信息分层方式：用 `SKILL.md` 做入口与导航，把细化说明放进 `references/`，仅在确有独立默认提示价值时再增加 `agents/openai.yaml`。

## 目标

- 统一展示结构，而不改变各个 skill 原本的适用场景、职责边界和规范强度。
- 让另一个 Codex 实例先从 `SKILL.md` 快速建立判断，再按需读取 `references/`，避免一次性加载过多细节。
- 让未来新增 skill 时直接沿用同一组织方式，而不是重新发明目录结构。

## 标准结构

```text
<skill-name>/
  SKILL.md
  references/            # 按需提供
    *.md
  agents/                # 按需提供
    openai.yaml
```

- MUST: 每个 skill 必须保留 `SKILL.md`。
- SHOULD: `SKILL.md` 只保留触发后立即需要知道的目标、边界、主流程和检查清单。
- SHOULD: 将 schema、布局约定、长篇验证细则、风险清单、迁移说明等高密度内容下沉到 `references/*.md`。
- SHOULD: 在 `SKILL.md` 中用 `SEE:` 直接指向本 skill 自己的 `references/*.md`。
- MUST: 不要为了结构统一而改变 frontmatter 中的 `name`，也不要改写 skill 原本的核心含义。

## SKILL.md 写法

- SHOULD: 保留简洁的入口结构，例如“核心目标”“边界说明”“主流程/执行规则”“交付检查清单”。
- SHOULD: 只有在确实有助于理解时才保留“何时使用”；frontmatter `description` 仍是主要触发入口。
- MUST: `SKILL.md` 中保留每个 skill 最关键的 MUST/SHOULD 规则，不把主文档瘦身到失去可执行性。
- SHOULD: 当某一块内容已经拆到 `references/` 后，在主文档中保留一句概括和对应 `SEE:`，不要复制整段细则。
- MUST: 所有 `SEE:` 链接都应直接从 `SKILL.md` 指向目标文件，避免多层跳转。

## References 写法

- SHOULD: 每个参考文件只承载一个相对稳定的主题，例如环境选择、布局导出、版本归组、兼容性边界。
- SHOULD: 文件名使用短横线命名，并直接体现主题。
- SHOULD: 若某个参考文件超过约 100 行，开头补一个简短目录，方便快速预览。
- MUST: 参考文件中的规则只能细化或展开已有语义，不能偷偷扩张 skill 的职责边界。
- MUST: 不要让参考文件变成通用仓库文档；内容必须仍然服务于所属 skill。

## Agents 写法

- SHOULD: 仅当某个 skill 明显适合独立的默认提示语、展示名和短描述时，才增加 `agents/openai.yaml`。
- SHOULD: 没有额外价值时，不要为了目录整齐机械新增 `agents/`。
- MUST: 若存在 `agents/openai.yaml`，其展示信息必须与 `SKILL.md` 保持一致，不能扩大或改写 skill 的用途。

## 迁移原则

- MUST: 迁移时逐条保留原有的 MUST/SHOULD/MAY 语义，不降低、不增强、不偷换范围。
- MUST: 不要因为拆分文档而改变 skill 之间的职责分工。
- SHOULD: 优先抽出那些已经明显过长、能形成稳定主题、会被重复参考的部分。
- SHOULD: 对本来已经很短、原则性很强的 skill，允许继续保持单文件结构。
