# README

GitHub项目网址：<https://github.com/beibingyangliuying/skills>

## install-skills.ps1

仓库根目录提供了 `install-skills.ps1`，用于从 GitHub 仓库远程下载某个 region 的 skills，并安装到指定 agent 目录。

当前脚本支持单个 region 安装，默认安装到脚本所在目录下的 `\.codex`。

### 用法

```powershell
./install-skills.ps1 --region <name> [--include <skill1,skill2>] [--exclude <skill1,skill2>] [--agent <codex|claude|path>] [--download-method <auto|iwr|curl|bits|webclient>] [--overwrite-all] [--skip-existing]
```

参数说明：

- `--region`：必填。指定要安装的 region，例如 `python`
- `--include`：可选。只安装列出的 skill，多个名称用英文逗号分隔
- `--exclude`：可选。排除列出的 skill，多个名称用英文逗号分隔
- `--agent`：可选。默认是 `codex`；也支持 `claude` 或自定义目录路径
- `--download-method`：可选。默认 `auto`；用于排障时强制指定下载器，可选 `iwr`、`curl`、`bits`、`webclient`
- `--overwrite-all`：可选。目标已存在时全部直接覆盖，不再逐项询问
- `--skip-existing`：可选。目标已存在时全部直接跳过，不再逐项询问

`--overwrite-all` 和 `--skip-existing` 不能同时传入；两者都不传时，默认是交互式逐项确认。

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

目标已存在时全部覆盖：

```powershell
./install-skills.ps1 --region python --overwrite-all
```

目标已存在时全部跳过：

```powershell
./install-skills.ps1 --region python --skip-existing
```

如果默认下载器在你的环境里握手失败，可以强制改用 `curl.exe`：

```powershell
./install-skills.ps1 --region python --download-method curl
```

### 执行前确认与执行后概要

脚本在真正写入前会先输出执行前概要，至少包括：

- 仓库地址
- 下载方式
- 冲突处理模式
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

默认情况下，如果目标位置已经存在同名 skill 目录，脚本会逐项提示选择：

- `Overwrite`
- `Skip`

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

2. 如果 `curl.exe` 可以，而默认运行失败，改用：

```powershell
./install-skills.ps1 --region python --download-method curl
```

3. 对比当前运行的是 `Windows PowerShell 5.1` 还是 `PowerShell 7+`：

```powershell
$PSVersionTable
```

4. 如果你在公司网络、代理或受管设备环境中，确认是否存在 HTTPS 代理、中间人证书或证书链信任要求。
