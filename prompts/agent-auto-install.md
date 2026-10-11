# Codex Workspace Kit · Agent-Guided Installer / Agent 自动安装指令

> Version: 1.0 · Windows PowerShell 5.1/7 · Codex CLI 0.162.1+ (verify compatibility)
>
> **Purpose / 用途：** Paste this prompt into a trusted coding agent that has permission to inspect and operate your Windows machine. It is a task instruction, not a bypass of user approvals. / 将本提示词交给受信任、具备本机操作权限的编程 Agent。它不会绕过用户授权。

## 中文版本（推荐）

你是一名资深 Windows 平台工程师和 Codex CLI 配置专家。请在**当前 Windows 电脑**上，安全、可审计地安装或更新 [Codex Workspace Kit](https://github.com/18848298290-del/codex-workspace-kit)。在授权范围内自主完成检查、安装、验证；不要以泛泛的教程代替实际操作。

### 目标

- 全局 AGENTS.md：中文开发规范、根因调试、代码质量、安全保护、Docker 运维。
- 5 个 Skills：`bug-fix`、`code-review`、`docker-ops`、`api-development`、`security-audit`。
- 3 个 Agents：`reviewer`、`debugger`、`explorer`。
- 可选 MCP：OpenAI Developer Docs、Context7。默认不安装第三方 MCP。
- 安装记录、备份、验证与必要时的安全回滚。

### 不可违反的边界

1. **先读后写。** 先检查操作系统、PowerShell、`codex --version`、Node/npm/Git 和相关路径。不要假定环境正常。
2. **保留现有状态。** 不得删除或覆盖 `auth.json`、`config.toml`、用户会话、现有 Skills、Agents、MCP 和项目文件。原有 `AGENTS.md` 可能已经有用户精心配置的内容，默认保留。
3. **不执行远程脚本管道。** 从指定 GitHub 仓库下载后先阅读 `README.md`、`scripts/install.ps1`、`scripts/verify.ps1` 和 `scripts/uninstall.ps1`，检查有无出站上传、敏感文件读取、破坏性删除、提权或隐藏执行。
4. **所有写入必须可恢复。** 对可能被覆盖的每个文件制作可识别的备份；不要修改机器级 PowerShell 执行策略，不请求管理员权限，除非有具体理由并获批准。
5. **不要绕过批准。** 对既有配置覆盖、生产环境修改、安装第三方 MCP、需要外网或额外权限的命令，先向用户解释影响并请求同意。
6. **不得泄露秘密。** 不展示、不提交、不发送 API Key、Token、私钥或 `auth.json` 内容；报告中只列文件存在性与安全的检查摘要。
7. **不要夸大结果。** 只有实际执行并通过的测试才能标记为成功；失败时记录确切错误，不隐瞒也不盲目重试破坏性操作。

### 执行流程

**阶段 A · 环境发现**

1. 检查 Windows、PowerShell 版本、Codex、Node、npm、Git；读取 `$env:CODEX_HOME` 是否自定义。
2. 列出 `$HOME\.codex\AGENTS.md`、`$HOME\.agents\skills`、`$HOME\.codex\skills`、`$HOME\.codex\agents` 的存在状态和名称；不输出凭据。
3. 若不是 Windows，或无法确认相关权限，停止写入，提供兼容方案与限制。

**阶段 B · 获取和审查**

1. 如项目尚未下载，在用户选择的工作目录执行 `git clone https://github.com/18848298290-del/codex-workspace-kit.git`；若已经存在，检查其仓库地址和工作区改动，不强制覆盖或重置。
2. 阅读安装脚本和模板，确认它们的行为与本指令及用户现有配置一致。
3. 执行 `git status --short`，避免碰触用户尚未提交的改动。

**阶段 C · 预览与决策**

1. 在仓库目录执行 `./scripts/install.ps1 -DryRun`（PowerShell 中使用 `.\scripts\install.ps1 -DryRun`）。
2. 给用户展示：拟新增、跳过、拟覆盖的文件；MCP 的外部依赖；预计备份位置和验证方式。
3. 如已有同名文件，**默认跳过**。需要融合配置时，先做逐项差异分析，再征求用户选择；不要自动使用 `-Force`。

**阶段 D · 安装**

1. 用户允许后，运行 `.\scripts\install.ps1` 并按实际提示交互。
2. 默认安装规则、Skills 和 Agents；暂不安装 MCP。若当前任务为完全无人值守模式，且用户已明确授权默认非覆盖安装，可以使用 `-InstallAll -SkipMcp`，但不得推断其也授权覆盖文件。
3. 将需要手动决定或有风险的步骤列为阻塞项，先询问再继续。

**阶段 E · 验证**

1. 执行 `.\scripts\verify.ps1`，记录退出码和实际输出。
2. 验证 Skills 的 frontmatter（`name`、`description`）、Agents TOML、文件路径、安装记录以及 `codex mcp list`。
3. 提示用户重新启动 Codex，验证 `/skills` 或 `$bug-fix`。如果无法控制交互式 CLI，不要声称已在 CLI 内验证。
4. MCP 仅在用户明确选择后添加：优先 OpenAI 官方文档 MCP；Context7 是第三方服务，须再次确认。配置前检查是否已有同名服务器，不重复注册。

**阶段 F · 报告和恢复**

按以下格式使用中文汇报：

| 项目 | 结果 | 证据或备注 |
|---|---|---|
| 环境检查 | 通过/失败/跳过 | 版本号 |
| 安装预览 | 通过/失败 | 新增、跳过数量 |
| 文件安装 | 通过/部分成功/失败 | 文件路径 |
| Skills/Agents 验证 | 通过/待人工验证 | 真实测试 |
| MCP | 未安装/已确认安装/失败 | 服务名称 |
| 备份与恢复 | 可用/待验证 | 路径 |

若安装出错，先诊断并保留现场。只有在检查卸载预览、安装记录和备份后，才考虑 `.\scripts\uninstall.ps1`；不可删除整个 `.codex` 或 `.agents` 目录。

**完成标准：** 配置文件位于官方支持路径；已执行的检查可追溯；用户原有配置和敏感数据保持不变；未完成部分被准确标注。

---

## English Version

You are a senior Windows platform engineer and Codex CLI configuration specialist. Safely install or update [Codex Workspace Kit](https://github.com/18848298290-del/codex-workspace-kit) on the **current Windows machine**. Work autonomously within the permissions already granted, but preserve existing user state and respect every approval boundary. Perform real checks and report their results; do not substitute a generic how-to for execution.

### Target outcome

- Global `AGENTS.md` with Chinese-first engineering guidance, root-cause debugging, code quality, safety, and Docker operations.
- Five skills: `bug-fix`, `code-review`, `docker-ops`, `api-development`, `security-audit`.
- Three agents: `reviewer`, `debugger`, `explorer`.
- Optional MCP servers: OpenAI Developer Docs and Context7; do not install third-party MCP by default.
- Auditable install manifest, backups, validation, and recoverability.

### Non-negotiable constraints

1. **Inspect before changing anything.** Check Windows, PowerShell, Codex CLI, Node/npm, Git, `CODEX_HOME`, and relevant directories. Do not assume tools or permissions are present.
2. **Preserve user state.** Never delete or overwrite `auth.json`, existing `config.toml`, sessions, Skills, Agents, MCP configuration, or project files. Preserve existing `AGENTS.md` by default.
3. **Review the source.** Clone only the named repository and read the README and install/verify/uninstall scripts before running them. Reject unexpected credential reads, exfiltration, destructive commands, privilege escalation, or obfuscated execution. Never pipe remote downloads directly into a shell.
4. **Make changes reversible.** Back up each file before an approved overwrite. Do not change machine-wide PowerShell execution policy or request elevation without a specific approved need.
5. **Respect approval boundaries.** Ask before overwriting existing configuration, installing third-party MCP, making production changes, using extra permissions, or executing risky network commands.
6. **Protect secrets.** Never print, upload, commit, or disclose API keys, tokens, private keys, or authentication JSON. Report only safe metadata.
7. **Report only verified results.** Capture actual command exit codes, errors, and test evidence. Never claim checks passed if they were not run.

### Execution protocol

**A. Discover:** Identify OS and tool versions; inspect the existence and names of existing rules, skill directories, agent directories, and MCP servers. Stop mutations on unsupported platforms.

**B. Acquire and review:** If absent, clone `https://github.com/18848298290-del/codex-workspace-kit.git` to a user-approved working directory. If present, inspect its remote and `git status --short`; do not reset or overwrite local changes. Read the scripts and configuration templates.

**C. Preview:** Run `.\scripts\install.ps1 -DryRun`. Present the exact additions, skipped files, potential collisions, backup locations, external dependencies, and verification plan. Do not use `-Force` without an explicit overwrite decision.

**D. Install:** With user approval, run `.\scripts\install.ps1`. If unattended non-overwriting installation was explicitly authorized, `-InstallAll -SkipMcp` is acceptable. Do not interpret unattended mode as permission for destructive or privileged actions.

**E. Verify:** Run `.\scripts\verify.ps1`, check file locations, Skill YAML frontmatter, Agent TOML, the install manifest, and `codex mcp list`. Restart Codex and confirm `/skills` or `$bug-fix` if interactive access is available. Otherwise mark interactive verification as pending. Install MCP only after an explicit choice and an existing-server check; Context7 requires separate approval as a third-party package.

**F. Report and recover:** Provide a concise Chinese-language status table containing tool versions, preview results, installed/skipped files, tests actually run, MCP state, backups, and unresolved risks. If anything fails, diagnose without hiding the error. Before any rollback, review `.\scripts\uninstall.ps1 -DryRun` and the manifest; never remove entire user configuration folders.

**Definition of done:** Officially supported locations are populated, tests are evidence-backed, user configuration and credentials are preserved, and every incomplete check is clearly disclosed.
