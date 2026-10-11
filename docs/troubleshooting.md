# Troubleshooting / 常见问题

This bilingual guide covers common discovery, installation and MCP issues. / 本指南提供技能发现、安装与 MCP 故障的常见排查方法。

## Skill missing from `/skills` / 技能未显示

1. 确认 `$HOME\.agents\skills\bug-fix\SKILL.md` 存在。 / Confirm the skill file exists.
2. 文件开头必须是 YAML frontmatter，包含 `name` 与 `description`。 / Validate its YAML metadata.
3. 完全退出并重新运行 `codex`。检查 `$env:CODEX_HOME` 是否指向自定义配置目录。 / Restart Codex and check `CODEX_HOME`.
4. 使用 `Get-Content ... -Raw -Encoding UTF8` 检查文件真实内容，而不是仅凭行数判断。 / Inspect the actual text rather than relying on line counts.

## AGENTS.md skipped / 全局规则被跳过

这是保护已有配置的默认行为。先比较新旧文件，确有需要再使用 `-Force`，脚本会备份原文件。 / Existing files are intentionally skipped. Compare differences before using `-Force`; backups are made first.

## MCP unavailable / MCP 不可用

执行 `codex mcp list`，检查服务器命令和网络；Context7 需要 Node.js/npm/npx。不要把密钥贴到公共 Issue。 / Inspect the MCP list, server commands and connectivity. Context7 needs Node.js/npm/npx; never post tokens in public issues.

## Restore previous files / 还原

运行 `.\scripts\uninstall.ps1 -DryRun` 检查影响，再执行正式卸载。备份在 `$HOME\.codex-workspace-kit\backups`。 / Preview uninstall first. Timestamped backups are stored under the listed directory.

## Reporting a bug / 提交问题报告

Include Codex and PowerShell versions, the failed command, redacted logs, and dry-run results. Never upload `auth.json`, private keys, tokens or unredacted environment variables. / 请提供版本、失败命令、脱敏日志及预览结果，不要上传登录文件、私钥或 Token。
