# Installation

Windows setup, verification and recovery.

Windows 安装、验证与恢复指南。

---

## 简体中文

### 环境要求

- Windows 10/11，PowerShell 5.1 或 7。
- Codex CLI、Node.js、npm 和 Git。
- 本项目以 Codex CLI 0.162.1 为适配目标，其他版本需验证。

### 安装

```powershell
# 检查工具
codex --version
node -v
npm -v
git --version

# 下载项目
git clone https://github.com/18848298290-del/codex-workspace-kit.git
cd codex-workspace-kit

# 先预览，再安装
.\scripts\install.ps1 -DryRun
.\scripts\install.ps1

# 验证
.\scripts\verify.ps1
```

安装程序默认跳过已有同名文件，不会自动覆盖 `AGENTS.md` 或 `config.toml`。如果需要替换，请先比较新旧文件，并明确决定是否使用 `-Force`；脚本会在替换前保留备份。

请重新启动 Codex，通过 `/skills` 或 `$bug-fix` 检查技能是否出现。脚本静态检查不能代替交互式验证。

### 可选 MCP

```powershell
.\scripts\install.ps1 -InstallMcp -DryRun
codex mcp list
```

脚本只展示 MCP 命令，不自动运行第三方包。确认服务来源及权限后再手动添加。

### 卸载与恢复

```powershell
.\scripts\uninstall.ps1 -DryRun
.\scripts\uninstall.ps1
```

卸载仅处理安装清单内的文件，并保护用户后续修改过的内容。不会删除登录信息、会话或整个配置目录。

如果 PowerShell 阻止执行脚本，可在组织策略允许的前提下，仅对当前终端进程临时设置 `Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass`。不要修改机器级策略，也不要直接执行联网脚本管道。

---

## English

### Requirements

- Windows 10/11 with PowerShell 5.1 or 7.
- Codex CLI, Node.js, npm and Git.
- Targeted at Codex CLI 0.162.1; verify compatibility with other versions.

### Setup

```powershell
codex --version
node -v
npm -v
git --version

git clone https://github.com/18848298290-del/codex-workspace-kit.git
cd codex-workspace-kit

.\scripts\install.ps1 -DryRun
.\scripts\install.ps1
.\scripts\verify.ps1
```

Existing target files are skipped by default. The installer will not automatically replace `AGENTS.md` or `config.toml`. Review differences and explicitly approve `-Force` before replacing a file; the original is backed up first.

Restart Codex and inspect `/skills` or invoke `$bug-fix`. Script-based checks do not constitute interactive CLI verification.

### Optional MCP

```powershell
.\scripts\install.ps1 -InstallMcp -DryRun
codex mcp list
```

MCP commands are displayed, not executed. Review the provider and its permissions before adding any server.

### Uninstall and restore

```powershell
.\scripts\uninstall.ps1 -DryRun
.\scripts\uninstall.ps1
```

Uninstall only processes manifest-tracked files and preserves user modifications, credentials, sessions and configuration directories.

If execution policy blocks local scripts, a process-scoped adjustment (`Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass`) may be used only when allowed by your security policy. Never change machine-wide policy or pipe remote scripts directly into a shell.
