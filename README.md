# README

GitHub项目网址：<https://github.com/beibingyangliuying/skills>

## install-skills.ps1

仓库根目录提供了 `install-skills.ps1`，用于从 GitHub 仓库远程下载某个 region 的 skills，并执行两类操作：

- 安装到指定 agent 目录
- 列出该 region 下可用的 skill 名称

当前脚本采用子命令形式，支持单个 region 的 `install` 和 `list` 操作；默认安装目标仍是脚本所在目录下的 `\.codex`。

### 用法

```powershell
./install-skills.ps1 install --region <name> [--include <skill1,skill2>] [--exclude <skill1,skill2>] [--agent <codex|claude|path>] [--download-method <auto|iwr|curl|bits|webclient>] [--overwrite-all] [--skip-existing]
./install-skills.ps1 list --region <name> [--download-method <auto|iwr|curl|bits|webclient>]
```

参数说明：

- `install`：安装指定 region 下的 skills 到 agent 目录
- `list`：列出指定 region 下远端仓库中的可用 skill 名称
- `--region`：必填。指定要处理的 region，例如 `python`
- `--include`：仅 `install` 支持。只安装列出的 skill，多个名称用英文逗号分隔
- `--exclude`：仅 `install` 支持。排除列出的 skill，多个名称用英文逗号分隔
- `--agent`：仅 `install` 支持。默认是 `codex`；也支持 `claude` 或自定义目录路径
- `--download-method`：`install` 和 `list` 都支持。默认 `auto`；用于排障时强制指定下载器，可选 `iwr`、`curl`、`bits`、`webclient`
- `--overwrite-all`：仅 `install` 支持。目标已存在时全部直接覆盖，不再逐项询问
- `--skip-existing`：仅 `install` 支持。目标已存在时全部直接跳过，不再逐项询问

`install` 子命令中，`--overwrite-all` 和 `--skip-existing` 不能同时传入；两者都不传时，默认是交互式逐项确认。

`install` 如果不传 `--include` 和 `--exclude`，默认安装该 region 下的全部 skills。脚本在真正写入前总会先展示 execution plan，并要求用户再确认一次；该确认直接回车时默认按 `Y` 继续。

`list` 是只读操作，会从远端仓库读取该 region 下的 skill 列表，输出 region 名称、skill 数量和逐行 skill 名称，不会执行任何本地写入。

旧写法 `./install-skills.ps1 --region python` 已不再支持，必须显式使用 `install` 或 `list` 子命令。

### 目录规则

- `--agent codex` 安装到 `<scriptRoot>\.codex`
- `--agent claude` 安装到 `<scriptRoot>\.claude`
- 其他 `--agent` 值会被当作自定义 agent 根目录
- skills 会安装到 `<agentRoot>\skills\<skillName>`
- `AGENTS.md` 会安装到 `<agentRoot>\AGENTS.md`

这里的 `<scriptRoot>` 指的是 `install-skills.ps1` 文件本身所在的目录，不是当前终端所在目录。

### 示例

安装 `python` region 下的全部 skills 到默认的 codex 目录：

```powershell
./install-skills.ps1 install --region python
```

只安装指定的两个 skills：

```powershell
./install-skills.ps1 install --region python --include pandas-dataframe,repo-workflow
```

安装除某个 skill 之外的全部内容：

```powershell
./install-skills.ps1 install --region python --exclude local-wheel-reuse
```

安装到 claude 目录：

```powershell
./install-skills.ps1 install --region python --agent claude
```

安装到自定义目录：

```powershell
./install-skills.ps1 install --region python --agent C:\temp\my-agent
```

目标已存在时全部覆盖：

```powershell
./install-skills.ps1 install --region python --overwrite-all
```

目标已存在时全部跳过：

```powershell
./install-skills.ps1 install --region python --skip-existing
```

如果默认下载器在你的环境里握手失败，可以强制改用 `curl.exe`：

```powershell
./install-skills.ps1 install --region python --download-method curl
```

列出 `python` region 下远端仓库中的全部 skills：

```powershell
./install-skills.ps1 list --region python
```

列 skill 列表时强制改用 `curl.exe`：

```powershell
./install-skills.ps1 list --region python --download-method curl
```

### 执行前确认与执行后概要

`install` 子命令在真正写入前会先输出执行前概要，至少包括：

- 仓库地址
- 下载方式
- 冲突处理模式
- region 名称
- 目标 agent 根目录
- 即将安装的 skill 列表
- 将写入的 `AGENTS.md`
- 已发现的潜在冲突项

确认继续后，脚本才会开始复制文件。

`install` 执行完成后，脚本会输出执行后概要，说明：

- 新安装了哪些 skills
- 覆盖了哪些 skills
- 跳过了哪些 skills
- `AGENTS.md` 的处理结果
- 是否有失败项

### 冲突处理

默认情况下，`install` 如果目标位置已经存在同名 skill 目录，脚本会逐项提示选择：

- `Overwrite`
- `Skip`

在这些逐项冲突确认里，直接回车时默认选择 `Skip`。

如果目标根目录已经存在 `AGENTS.md`，同样会提示覆盖还是跳过。

如果传了 `--overwrite-all`，所有已存在项都会直接覆盖。

如果传了 `--skip-existing`，所有已存在项都会直接跳过。

默认不会静默覆盖或静默跳过现有内容。

### 故障排查

如果你看到类似下面的错误：

```text
The SSL connection could not be established, see inner exception.
```

通常不是脚本参数问题，而是当前 PowerShell 运行时的 HTTPS/TLS 栈和本机网络环境之间存在兼容性差异。脚本现在会自动按顺序尝试多个下载器：

- `Invoke-WebRequest`
- `curl.exe`
- `Start-BitsTransfer`
- `System.Net.WebClient`

另外，脚本报错时会额外输出：

- 当前 PowerShell 版本和 edition
- 下载 URL
- 每个下载器的失败摘要
- 最内层异常信息

建议按下面顺序排查：

1. 先直接测试 GitHub 下载链路：

```powershell
curl.exe -L https://github.com/beibingyangliuying/skills/archive/refs/heads/main.zip -o test.zip
```

1. 如果 `curl.exe` 可以，而默认运行失败，改用：

```powershell
./install-skills.ps1 install --region python --download-method curl
```

1. 对比当前运行的是 `Windows PowerShell 5.1` 还是 `PowerShell 7+`：

```powershell
$PSVersionTable
```

1. 如果你在公司网络、代理或受管设备环境中，确认是否存在 HTTPS 代理、中间人证书或证书链信任要求。
