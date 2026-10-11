# 配置说明

- `config/AGENTS.md`：所有项目通用的中文开发规则。用户原有的 `$HOME\.codex\AGENTS.md` 默认不覆盖。
- `skills/*/SKILL.md`：符合 Skill 元数据规范的独立技能，安装到 `$HOME\.agents\skills`。
- `agents/*.toml`：自定义只读 Agent，安装到 `$HOME\.codex\agents`。
- `config/config.example.toml`：供参考的配置，不自动合并到 `$HOME\.codex\config.toml`，避免覆盖现有模型和 MCP。

重启 Codex 以加载新技能或 Agent。通过 `/skills` 查看，使用 `$bug-fix` 显式调用。自定义 `explorer` 会与 Codex 内置同名角色重合，当前模板默认可覆盖该角色的行为；若不需要，可不安装它。

## MCP

OpenAI 文档 MCP：

```powershell
codex mcp add openaiDeveloperDocs --url https://developers.openai.com/mcp
```

Context7 MCP（运行 npm 第三方包，须先审查）：

```powershell
codex mcp add context7 -- npx -y @upstash/context7-mcp
```

通过 `codex mcp list` 查看配置，通过 `codex mcp --help` 查询其他命令。MCP 不由本项目的卸载脚本自动移除，以免干扰用户已有同名配置。
