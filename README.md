# Codex Workspace Kit

面向 Windows 的 Codex CLI 配置工具包：全局指令、5 个开发 Skills、3 个专用 Agents 和可选 MCP。

> 适配目标：Codex CLI 0.162.1，Windows PowerShell 5.1/7。安装脚本不会读取或修改 `auth.json`。

## 快速开始

**想让编程 Agent 代为安装？** 将 [中英双语 Agent 自动安装提示词](prompts/agent-auto-install.md) 交给能操作你 Windows 电脑的受信任 Agent。它会要求先检查、预览、备份，再安装和验证，不会绕过高风险操作的用户确认。

```powershell
git clone https://github.com/18848298290-del/codex-workspace-kit.git
cd codex-workspace-kit
.\scripts\install.ps1 -DryRun
.\scripts\install.ps1
.\scripts\verify.ps1
```

若受 PowerShell 执行策略限制，可在当前进程临时授权后再运行（不修改全局策略）：

```powershell
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
```

安装程序默认只安装不存在的文件；遇到同名文件会跳过。通过 `-Force` 可以备份并替换本工具包管理的目标文件。通过 `-InstallAll` 跳过模块选择，仍然不会默认安装 MCP。MCP 需单独运行 `-InstallMcp`；可能下载并执行第三方包，请先审查来源。

```powershell
.\scripts\install.ps1 -InstallAll -SkipMcp
.\scripts\install.ps1 -InstallMcp -DryRun
```

## 组成

| 模块 | 安装位置 |
|---|---|
| 全局规则 | `$HOME\.codex\AGENTS.md` |
| Skills | `$HOME\.agents\skills\<name>\SKILL.md` |
| Agents | `$HOME\.codex\agents\<name>.toml` |
| 可选 MCP | 通过 `codex mcp add` 注册 |

安装记录和备份存放在 `$HOME\.codex-workspace-kit`。运行 `.\scripts\uninstall.ps1 -DryRun` 预览移除，由于卸载按文件哈希核对，用户修改过的文件不会被删除。

详细说明见 [安装指南](docs/installation.md)、[配置说明](docs/configuration.md) 和 [排障](docs/troubleshooting.md)。

## 安全原则

- 不含密钥、破解指令和第三方中转站配置。
- 不执行 `down -v`、数据库重置、凭据修改或大范围目录删除。
- 不覆盖与本项目无关的内容，不修改用户已有的 `config.toml`。
- 脚本在 Windows PowerShell 环境的实机验证仍需用户执行，不能将静态检查当作实机测试。

MIT License。
