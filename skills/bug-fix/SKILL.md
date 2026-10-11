---
name: bug-fix
description: Diagnose and fix reproducible bugs in a repository. Use when errors, crashes, failing tests, or unexpected behavior are reported.
---

# Bug 修复

1. 收集现象、预期结果、日志和相关环境信息；信息不足时说明假设。
2. 阅读调用链和现有测试，安全可行时复现。
3. 找出根本原因并选择最小、可维护的修复。
4. 在任务授权范围内实施修改，补充适当回归测试。
5. 运行相关测试和静态检查，复核改动范围。
6. 用中文报告根因、修改文件、验证证据、限制与风险。

绝不虚构测试结果，不清空数据，不覆盖无关修改。
