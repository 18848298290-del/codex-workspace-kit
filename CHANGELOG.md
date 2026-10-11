# Changelog / 更新日志

All notable changes are documented here. / 此处记录重要改动。

## v0.1.1 — Installer hardening / 安装器稳定性改进

**English**

- Plan and preview all file operations before changing any destination.
- Roll back modified files and the manifest if installation fails partway through.
- Preserve ownership boundaries: pre-existing identical files are observed but not adopted for uninstall.
- Reject symbolic links and reparse points on source and target paths.
- Enforce a precise PowerShell 5.1 minimum version.
- Generate unique backup directories with milliseconds and a random suffix.
- Use literal paths for filesystem operations and show backup targets in dry-run output.
- Add isolated tests for installation, idempotency, rollback, pre-existing files and restore.

**简体中文**

- 所有写入先进行计划和预览。
- 安装中途失败时，恢复已经修改的文件和安装清单。
- 明确文件归属：原有同内容文件只记录为已观察到，不由卸载程序接管。
- 检测并拒绝来源及目标路径中的符号链接和重解析点。
- 精确要求 PowerShell 5.1 或更新版本。
- 采用毫秒时间戳与随机后缀，防止备份目录冲突。
- 使用字面量路径，并在预览时显示备份目标。
- 增加隔离安装、重复安装、失败回滚、原有文件保留与恢复测试。

## v0.1.0 — Initial release / 初始版本

- Global guidance, five Skills, three Agents, optional MCP guidance, Windows PowerShell installer and bilingual documentation.
- 全局开发规则、五个 Skills、三个 Agents、可选 MCP 指南、Windows 安装脚本及中英双语文档。

> The version heading documents source changes; it does not assert that a GitHub Release has been published. / 本文件仅记录源码版本，不代表已经发布 GitHub Release。
