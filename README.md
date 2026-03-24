# README

GitHub项目网址：<https://github.com/beibingyangliuying/skills>

## install-skills.ps1

仓库根目录提供了 `install-skills.ps1`，用于从 GitHub 仓库远程下载某个 region 的 skills，并安装到指定 agent 目录。

当前脚本支持单个 region 安装，默认安装到 `codex`，也就是 `%USERPROFILE%\.codex`。

### 用法

```powershell
./install-skills.ps1 --region <name> [--include <skill1,skill2>] [--exclude <skill1,skill2>] [--agent <codex|claude|path>]
```

参数说明：

- `--region`：必填。指定要安装的 region，例如 `python`
- `--include`：可选。只安装列出的 skill，多个名称用英文逗号分隔
- `--exclude`：可选。排除列出的 skill，多个名称用英文逗号分隔
- `--agent`：可选。默认是 `codex`；也支持 `claude` 或自定义目录路径

### 目录规则

- `--agent codex` 安装到 `%USERPROFILE%\.codex`
- `--agent claude` 安装到 `%USERPROFILE%\.claude`
- 其他 `--agent` 值会被当作自定义 agent 根目录
- skills 会安装到 `<agentRoot>\skills\<skillName>`
- `AGENTS.md` 会安装到 `<agentRoot>\AGENTS.md`

### 示例

安装 `python` region 下的全部 skills 到默认的 codex 目录：

```powershell
./install-skills.ps1 --region python
```

只安装指定的两个 skills：

```powershell
./install-skills.ps1 --region python --include pandas-dataframe,repo-workflow
```

安装除某个 skill 之外的全部内容：

```powershell
./install-skills.ps1 --region python --exclude local-wheel-reuse
```

安装到 claude 目录：

```powershell
./install-skills.ps1 --region python --agent claude
```

安装到自定义目录：

```powershell
./install-skills.ps1 --region python --agent C:\temp\my-agent
```

### 执行前确认与执行后概要

脚本在真正写入前会先输出执行前概要，至少包括：

- 仓库地址
- region 名称
- 目标 agent 根目录
- 即将安装的 skill 列表
- 将写入的 `AGENTS.md`
- 已发现的潜在冲突项

确认继续后，脚本才会开始复制文件。

执行完成后，脚本会输出执行后概要，说明：

- 新安装了哪些 skills
- 覆盖了哪些 skills
- 跳过了哪些 skills
- `AGENTS.md` 的处理结果
- 是否有失败项

### 冲突处理

如果目标位置已经存在同名 skill 目录，脚本会逐项提示选择：

- `Overwrite`
- `Skip`

如果目标根目录已经存在 `AGENTS.md`，同样会提示覆盖还是跳过。

默认不会静默覆盖现有内容。
