# 安装指南（Windows）

1. 安装 Codex CLI、Node.js 和 Git，使用 `codex --version`、`node -v`、`git --version` 验证。
2. `git clone https://github.com/18848298290-del/codex-workspace-kit.git`。
3. `cd codex-workspace-kit`，执行 `.\scripts\install.ps1 -DryRun` 预览目标文件。
4. 阅读输出并确认后执行 `.\scripts\install.ps1`，在提示时输入 `YES`。
5. 已有文件默认跳过。确实需要替换时，先自行备份，再使用 `-Force`；脚本也会自动保存替换前副本。
6. 执行 `.\scripts\verify.ps1`，重新启动 Codex，输入 `/skills` 或 `$bug-fix` 检查。

如 PowerShell 阻止执行，可以用 `Set-ExecutionPolicy -Scope Process Bypass` 仅在当前终端窗口临时允许。不要采用联网管道直接执行脚本。

## MCP（可选）

运行 `.\scripts\install.ps1 -InstallMcp -DryRun` 查看建议命令。请先审核服务器来源，再自行执行命令；MCP 服务可能具备读取项目内容或访问外部网络的能力。

## 卸载

`.\scripts\uninstall.ps1 -DryRun` 预览，确认后执行 `.\scripts\uninstall.ps1`。已被用户修改的文件会保留；卸载不会删除 `auth.json`、会话、其他 Skills 或整个配置目录。
