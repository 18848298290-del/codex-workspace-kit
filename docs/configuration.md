# Configuration Reference / 配置说明

This document describes what the installer manages and what it deliberately leaves untouched. / 本文说明安装程序管理哪些配置，以及哪些内容会被刻意保留。

- `config/AGENTS.md`：所有项目通用的中文开发规则。用户原有的 `$HOME\.codex\AGENTS.md` 默认不覆盖。 / Global Chinese-first development instructions; existing files are skipped.
- `skills/*/SKILL.md`：符合 Skill 元数据规范的独立技能，安装到 `$HOME\.agents\skills`。 / Standalone skills with metadata and task-specific workflows.
- `agents/*.toml`：自定义只读 Agent，安装到 `$HOME\.codex\agents`。 / Focused read-only subagents.
- `config/config.example.toml`：供参考的配置，不自动合并到 `$HOME\.codex\config.toml`，避免覆盖现有模型和 MCP。 / Example only; never merged automatically into existing user configuration.

重启 Codex 以加载新技能或 Agent。通过 `/skills` 查看，使用 `$bug-fix` 显式调用。自定义 `explorer` 会与 Codex 内置同名角色重合，当前模板默认可覆盖该角色的行为；若不需要，可不安装它。 / Restart Codex after installation; use `/skills` or `$bug-fix`. The custom `explorer` shares a name with a built-in role and may override it, so consider whether you need it.

## MCP integrations / MCP 集成

OpenAI Developer Docs MCP / OpenAI 官方文档：

```powershell
codex mcp add openaiDeveloperDocs --url https://developers.openai.com/mcp
```

Context7 MCP (third-party npm package; review before executing) / 第三方 npm 包，使用前审查：

```powershell
codex mcp add context7 -- npx -y @upstash/context7-mcp
```

通过 `codex mcp list` 查看配置，通过 `codex mcp --help` 查询其他命令。MCP 不由本项目的卸载脚本自动移除，以免干扰用户已有同名配置。 / Check status with `codex mcp list`. The uninstall script deliberately leaves MCP registrations intact so it cannot erase a pre-existing server with the same name.

## Backups / 备份

The manifest is stored at `$HOME\.codex-workspace-kit\manifest.json`. Backups of approved overwrites use timestamped folders under `backups/`. Files modified after installation are preserved during uninstall. / 安装清单保存在上述目录；获准覆盖的旧文件会保存到时间戳备份目录，安装后修改过的文件会在卸载时保留。
