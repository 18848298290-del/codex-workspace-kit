# Troubleshooting

Practical diagnostics, without destructive resets.

先定位问题，再采取最小必要操作。

---

## 简体中文

### `/skills` 没有找到技能

1. 确认 `$HOME\.agents\skills\bug-fix\SKILL.md` 存在。
2. 检查文件开头是否有合法 YAML 元数据：`name` 和 `description`。
3. 完全退出并重新启动 Codex。
4. 检查 `$env:CODEX_HOME` 是否使用自定义目录。

```powershell
Test-Path "$HOME\.agents\skills\bug-fix\SKILL.md"
Get-Content "$HOME\.agents\skills\bug-fix\SKILL.md" -TotalCount 8 -Encoding UTF8
$env:CODEX_HOME
```

### 安装时跳过了 `AGENTS.md`

这是默认的保护行为。先比较现有文件和仓库模板；只有确认需要替换时才使用 `-Force`，并核对备份是否生成。

### MCP 无法连接

运行 `codex mcp list`，检查服务器名称、命令、网络和 Node/npm 环境。第三方 MCP 可能需要联网下载；不要把 Token 上传到公开 Issue。

### 如何恢复

```powershell
.\scripts\uninstall.ps1 -DryRun
.\scripts\uninstall.ps1
```

先预览，再决定是否执行。备份位于 `$HOME\.codex-workspace-kit\backups`。不要删除整个用户配置目录。

---

## English

### A Skill is missing from `/skills`

1. Confirm `$HOME\.agents\skills\bug-fix\SKILL.md` exists.
2. Check that its YAML frontmatter includes `name` and `description`.
3. Restart Codex completely.
4. Check whether `CODEX_HOME` points to a custom location.

```powershell
Test-Path "$HOME\.agents\skills\bug-fix\SKILL.md"
Get-Content "$HOME\.agents\skills\bug-fix\SKILL.md" -TotalCount 8 -Encoding UTF8
$env:CODEX_HOME
```

### `AGENTS.md` was skipped

This is intentional. Compare the existing file and the template. Use `-Force` only after approving a replacement and checking that a backup will be made.

### MCP connection fails

Run `codex mcp list`. Inspect server configuration, connectivity, and Node/npm availability. Third-party MCP packages may require downloads; never post credentials in public issues.

### Restore previous files

```powershell
.\scripts\uninstall.ps1 -DryRun
.\scripts\uninstall.ps1
```

Preview first. Backups live under `$HOME\.codex-workspace-kit\backups`. Never delete the entire Codex configuration directory as a troubleshooting step.

---

## Reporting issues / 反馈问题

Include the Codex and PowerShell versions, the failing command, a sanitized error log, and whether dry run succeeded. Never attach `auth.json`, API tokens, private keys or unredacted environment variables.

请提供 Codex 与 PowerShell 版本、失败命令、脱敏日志及预览结果。切勿上传登录凭据或未脱敏的环境变量。
