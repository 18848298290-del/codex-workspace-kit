# Configuration

A small set of components, clear ownership, no hidden changes.

精简的配置组件、明确的管理边界、不做隐式修改。

---

## Layout / 目录结构

| Source | Windows destination |
|:--|:--|
| `config/AGENTS.md` | `$HOME\.codex\AGENTS.md` |
| `skills/*/SKILL.md` | `$HOME\.agents\skills\<name>\SKILL.md` |
| `agents/*.toml` | `$HOME\.codex\agents\<name>.toml` |
| `config/config.example.toml` | Reference only / 仅供参考 |

## 简体中文

### 全局规则

`AGENTS.md` 提供中文沟通、自主开发、根因修复、代码质量、安全和 Docker 规范。若用户已配置同名文件，安装程序默认跳过，不自动合并或覆盖。`config.example.toml` 仅作为参考，不会改动当前模型和权限设置。

### Skills

- `bug-fix`：Bug 根因分析与回归验证。
- `code-review`：基于证据的代码审查。
- `docker-ops`：容器运维、持久化与安全部署。
- `api-development`：HTTP API 开发与测试。
- `security-audit`：授权范围内的防御性审计。

安装后重启 Codex，在 `/skills` 中检查或通过 `$bug-fix` 显式使用。

### Agents

`reviewer`、`debugger`、`explorer` 分别负责审查、故障定位和项目探索。它们默认只读。自定义 `explorer` 与 Codex 内置角色同名，可能覆盖内置行为；不需要时可以不安装。

### MCP（可选）

```powershell
codex mcp add openaiDeveloperDocs --url https://developers.openai.com/mcp
codex mcp add context7 -- npx -y @upstash/context7-mcp
codex mcp list
```

以上是手动命令。Context7 属于第三方 npm 包，请先审查其来源。卸载脚本不会自动删除 MCP 注册，以免影响原本存在的同名服务。

### 安装记录

受管理文件的哈希记录在 `$HOME\.codex-workspace-kit\manifest.json`，获准覆盖的原文件备份位于 `backups/` 子目录。卸载时会保留已被用户修改的文件。

---

## English

### Global guidance

`AGENTS.md` defines communication, autonomous coding, root-cause debugging, quality, safety, and Docker practices. Existing files are skipped by default. The example TOML file is reference-only and never alters the current model or permissions.

### Skills

- `bug-fix` — root-cause diagnosis and regression testing.
- `code-review` — evidence-led actionable reviews.
- `docker-ops` — containers, persistence, and deployment safety.
- `api-development` — HTTP API engineering and testing.
- `security-audit` — authorized defensive security review.

Restart Codex to discover new Skills. Inspect `/skills` or invoke `$bug-fix`.

### Agents

`reviewer`, `debugger`, and `explorer` specialize in reviewing, diagnosing failures, and mapping repositories. Each defaults to read-only operation. The custom `explorer` shares its name with a built-in Codex agent and may override that behavior.

### Optional MCP

```powershell
codex mcp add openaiDeveloperDocs --url https://developers.openai.com/mcp
codex mcp add context7 -- npx -y @upstash/context7-mcp
codex mcp list
```

These are manual commands. Context7 is a third-party npm package; review it before use. Uninstall deliberately leaves MCP registrations intact to avoid removing pre-existing integrations.

### Installation records

Managed file hashes are tracked in `$HOME\.codex-workspace-kit\manifest.json`. Approved replacements are backed up under `backups/`. User-modified files are preserved during uninstall.
