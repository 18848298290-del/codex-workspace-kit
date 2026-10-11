# 常见问题

## `/skills` 中看不到技能

1. 确认 `$HOME\.agents\skills\bug-fix\SKILL.md` 存在。
2. 文件开头必须是 YAML frontmatter，包含 `name` 与 `description`。
3. 完全退出并重新运行 `codex`。检查 `$env:CODEX_HOME` 是否指向自定义配置目录。
4. 使用 `Get-Content ... -Raw -Encoding UTF8` 检查文件真实内容，而不是仅凭行数判断。

## 安装跳过 AGENTS.md

这是保护已有配置的默认行为。先比较新旧文件，确有需要再使用 `-Force`，脚本会备份原文件。

## MCP 不可用

执行 `codex mcp list`，检查服务器命令和网络；Context7 需要 Node.js/npm/npx。不要把密钥贴到公共 Issue。

## 还原

运行 `.\scripts\uninstall.ps1 -DryRun` 检查影响，再执行正式卸载。备份在 `$HOME\.codex-workspace-kit\backups`。
