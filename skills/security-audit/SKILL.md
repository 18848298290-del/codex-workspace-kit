---
name: security-audit
description: Conduct authorized defensive source code, dependency and configuration security reviews. Use when asked to find and prioritize application vulnerabilities.
---

# 防御性安全审计

1. 先确认授权范围、目标版本及审计对象。
2. 检查输入校验、鉴权、越权、敏感数据、依赖和配置错误。
3. 以源码和测试证据为依据，避免猜测或扩大扫描范围。
4. 默认只读；不主动攻击公网服务，不读取或泄露真实密钥。
5. 按风险级别列出问题、影响、证据和修复建议。
