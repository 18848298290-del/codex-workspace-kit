# Installation Guide / 安装指南（Windows）

This guide walks through a conservative installation on Windows. It preserves existing settings by default and includes preview, validation, and rollback steps. / 本文介绍 Windows 上的保守安装流程，默认保护已有配置，并提供预览、验证和恢复步骤。

1. 安装 Codex CLI、Node.js 和 Git，使用 `codex --version`、`node -v`、`git --version` 验证。 / Install Codex CLI, Node.js, and Git; verify their versions.
2. `git clone https://github.com/18848298290-del/codex-workspace-kit.git`。 / Clone the repository.
3. `cd codex-workspace-kit`，执行 `.\scripts\install.ps1 -DryRun` 预览目标文件。 / Preview changes before installing.
4. 阅读输出并确认后执行 `.\scripts\install.ps1`，在提示时输入 `YES`。 / Run the installer, then type `YES` when prompted.
5. 已有文件默认跳过。确实需要替换时，先自行备份，再使用 `-Force`；脚本也会自动保存替换前副本。 / Existing files are skipped; use `-Force` only after reviewing the differences and approving a backup-and-replace operation.
6. 执行 `.\scripts\verify.ps1`，重新启动 Codex，输入 `/skills` 或 `$bug-fix` 检查。 / Run validation, restart Codex, and test skill discovery interactively.

如 PowerShell 阻止执行，可以用 `Set-ExecutionPolicy -Scope Process Bypass` 仅在当前终端窗口临时允许。不要采用联网管道直接执行脚本。 / If your security policy permits it, adjust execution policy for the current process only. Never pipe remote scripts straight to a shell.

## Optional MCP / MCP（可选）

运行 `.\scripts\install.ps1 -InstallMcp -DryRun` 查看建议命令。请先审核服务器来源，再自行执行命令；MCP 服务可能具备读取项目内容或访问外部网络的能力。 / This only displays proposed commands. Review the provider before running them manually; MCP tools may access local code or external networks.

## Uninstall and recovery / 卸载与恢复

`.\scripts\uninstall.ps1 -DryRun` 预览，确认后执行 `.\scripts\uninstall.ps1`。已被用户修改的文件会保留；卸载不会删除 `auth.json`、会话、其他 Skills 或整个配置目录。 / Preview first, then confirm uninstall. User-modified files, credentials, sessions, unrelated skills and configuration directories are preserved.
