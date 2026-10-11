<div align="center">

# Codex Workspace Kit

### A considered workspace for Codex CLI.

为 Codex CLI 打造的专业开发工作环境。

**Windows · PowerShell · Codex CLI**

[Get Started](#get-started--快速开始) &nbsp;·&nbsp; [Documentation](#documentation--文档) &nbsp;·&nbsp; [Agent Setup](prompts/agent-auto-install.md)

</div>

---

## Built for the way you work.

Codex Workspace Kit brings a clear set of engineering principles, focused coding skills and specialized agents into one reproducible setup. It is designed to integrate with your existing environment — deliberately, transparently and without taking ownership of your personal configuration.

**专注开发，保持掌控。**

将开发规范、专业技能与专用 Agent 整合为可复用的 Codex 工作环境。尊重已有配置、明确每一次变更，让初始化和迁移变得简单可靠。

## What's inside / 核心组件

| | English | 中文 |
|:--|:--|:--|
| **Guidance** | Consistent engineering standards through `AGENTS.md` | 全局开发规范与安全边界 |
| **Skills** | Five task-oriented workflows | 五项专注实际开发的技能 |
| **Agents** | Three specialized, read-only roles | 三个专注分析与审查的 Agent |
| **MCP** | Optional developer documentation integrations | 按需连接开发文档服务 |
| **Tooling** | Preview, install, verify and recover | 安装预览、验证、备份与恢复 |

<details>
<summary><strong>Explore the included Skills & Agents / 查看技能与智能体</strong></summary>

### Skills

| Skill | Focus / 主要用途 |
|:--|:--|
| `bug-fix` | Root-cause debugging / 根因定位与修复 |
| `code-review` | Actionable code review / 代码审查 |
| `docker-ops` | Container operations / Docker 部署与排障 |
| `api-development` | API engineering / API 开发与测试 |
| `security-audit` | Defensive security review / 防御性安全审计 |

### Agents

| Agent | Focus / 主要用途 |
|:--|:--|
| `reviewer` | Correctness and regression risks / 正确性与回归风险 |
| `debugger` | Failures and call-chain analysis / 故障及调用链分析 |
| `explorer` | Repository and architecture exploration / 项目与架构探索 |

</details>

## Get started / 快速开始

Designed for **Windows 10/11** and **PowerShell 5.1/7**, targeting **Codex CLI 0.162.1**. Compatibility with other versions should be verified.

面向 Windows 10/11 与 PowerShell 5.1/7，以 Codex CLI 0.162.1 为适配目标。其他版本请先验证兼容性。

```powershell
git clone https://github.com/18848298290-del/codex-workspace-kit.git
cd codex-workspace-kit

# Inspect the changes first / 先预览变更
.\scripts\install.ps1 -DryRun

# Install / 执行安装
.\scripts\install.ps1

# Verify / 验证配置
.\scripts\verify.ps1
```

Existing files are **preserved by default**. The installer does not automatically execute third-party MCP packages or replace your `config.toml`.

**默认保留已有文件。** 安装程序不会自动运行第三方 MCP，也不会覆盖你的 `config.toml`。

### Prefer an autonomous setup? / 让 Agent 协助安装

Use the [Agent Installation Protocol](prompts/agent-auto-install.md) with a trusted coding agent that can access your Windows environment. It guides the process from inspection and review to installation, verification and recovery, while keeping approval for sensitive operations in your hands.

如果希望由编程 Agent 完成操作，可以使用 [Agent 自动安装协议](prompts/agent-auto-install.md)。它提供完整的检查、安装、验证和恢复流程，同时保留高风险操作的人工确认。

## Designed with restraint / 设计原则

**Predictable by default.** Existing configuration is respected; changes can be previewed before installation.

**Secure by design.** No bundled credentials, relay endpoints, forced third-party installs or destructive cleanup.

**Recoverable.** Managed files are tracked. Approved replacements are backed up and can be restored.

**以可预期为前提。** 默认保留现有配置，执行前可查看具体变更。

**以安全为基础。** 不内置密钥、中转地址或破坏性清理操作，不强制安装第三方组件。

**以可恢复为保障。** 跟踪受管理的文件，覆盖前备份，必要时可以恢复。

## Documentation / 文档

| Guide | 说明 |
|:--|:--|
| [Installation](docs/installation.md) | Windows 安装与卸载 |
| [Configuration](docs/configuration.md) | AGENTS.md、Skills、Agents 与 MCP |
| [Troubleshooting](docs/troubleshooting.md) | 常见问题与故障排查 |
| [Agent Installation Protocol](prompts/agent-auto-install.md) | 中英双语 Agent 自动安装指令 |
| [Changelog](CHANGELOG.md) | 版本与稳定性修复记录 |

---

<div align="center">

**Open source. Built to be yours.**

开源、透明，由你掌控。

[MIT License](LICENSE)

<sub>Initial release · Windows end-to-end testing is pending / 第一版 · Windows 全流程实机测试待完成</sub>

</div>
