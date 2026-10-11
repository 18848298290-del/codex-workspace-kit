# Codex Workspace Kit

**A safer, reusable Codex CLI development toolkit for Windows.**  
**面向 Windows 的安全、可复用 Codex CLI 开发环境工具包。**

This repository bundles global guidance, reusable skills, focused agents, optional MCP integrations, and PowerShell scripts for installation, validation and rollback.

本仓库整合全局开发规范、可复用技能、专用 Agent、可选 MCP 集成，以及用于安装、验证和恢复的 PowerShell 脚本。

面向 Windows 的 Codex CLI 配置工具包：全局指令、5 个开发 Skills、3 个专用 Agents 和可选 MCP。  
A ready-to-customize Codex CLI configuration kit: global instructions, five Skills, three Agents, and optional MCP.

> **Compatibility / 兼容性：** Codex CLI 0.162.1 (target version), Windows 10/11, PowerShell 5.1/7. The installer does not read or modify `auth.json`. / 适配目标为 Codex CLI 0.162.1，安装程序不读取或修改登录凭据。
>
> **Release status / 发布状态：** Initial release; Windows end-to-end verification is pending. / 第一版已发布，Windows 实机全流程验证仍待完成。

## Quick start / 快速开始

**Agent-guided installation / 让 Agent 自动安装：** Give the [bilingual agent installation prompt / 中英双语 Agent 自动安装提示词](prompts/agent-auto-install.md) to a trusted coding agent with access to your Windows computer. It guides safe inspection, dry run, backup, approval, installation, verification and recovery. / 将这份提示词交给受信任的编程 Agent，它会按检查、预览、备份、授权、安装、验证和恢复流程执行。

```powershell
git clone https://github.com/18848298290-del/codex-workspace-kit.git
cd codex-workspace-kit
.\scripts\install.ps1 -DryRun
.\scripts\install.ps1
.\scripts\verify.ps1
```

If allowed by your security policy, you can adjust PowerShell execution policy for the current process only. / 若组织安全策略允许，可以只对当前进程临时调整执行策略（不修改全局策略）：

```powershell
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
```

The installer skips existing target files by default. `-Force` backs up and replaces targeted files only after you deliberately choose to use it. `-InstallAll` is non-interactive and does not automatically install MCP. / 默认跳过同名文件；`-Force` 可在备份后替换目标文件，使用前必须明确确认。`-InstallAll` 以非交互方式安装，仍不自动安装 MCP。

```powershell
.\scripts\install.ps1 -InstallAll -SkipMcp
.\scripts\install.ps1 -InstallMcp -DryRun
```

## Components / 项目组成

| Component / 模块 | Installation path / 安装位置 |
|---|---|
| 全局规则 | `$HOME\.codex\AGENTS.md` |
| Skills | `$HOME\.agents\skills\<name>\SKILL.md` |
| Agents | `$HOME\.codex\agents\<name>.toml` |
| 可选 MCP | 通过 `codex mcp add` 注册 |

The installation manifest and backups are stored in `$HOME\.codex-workspace-kit`. Preview uninstall with `.\scripts\uninstall.ps1 -DryRun`; user-modified files are preserved by hash checks. / 安装记录和备份存放在上述目录，卸载会根据文件哈希保护已被用户修改的内容。

Read the bilingual [Installation Guide / 安装指南](docs/installation.md), [Configuration Reference / 配置说明](docs/configuration.md), and [Troubleshooting / 故障排查](docs/troubleshooting.md).

## Safety principles / 安全原则

- No secrets, jailbreak instructions or relay API configuration. / 不含密钥、越狱指令或第三方中转站配置。
- No destructive Docker volume deletion, database reset or credentials modification. / 不删除数据卷、不重置数据库、不修改凭据。
- No unrelated file overwrites or automatic changes to `config.toml`. / 不覆盖无关文件，不自动修改现有 `config.toml`。
- Windows live testing is still required; static checks are not live verification. / Windows 实机验证仍待完成，不将静态检查冒充实测。

## License and contributions / 开源协议与贡献

Released under the [MIT License](LICENSE). Issues and pull requests are welcome. Never attach secrets or sensitive logs. / 采用 MIT 开源协议，欢迎提交 Issue 和 PR，但请勿上传密钥或敏感日志。
