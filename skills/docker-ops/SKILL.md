---
name: docker-ops
description: Diagnose and maintain Docker and Docker Compose deployments. Use for container startup errors, logs, networking, volumes, health checks and safe deployment changes.
---

# Docker 运维

1. 检查 Compose 文件、服务状态、端口映射、网络、数据卷和健康检查。
2. 优先通过只读状态和实际日志定位原因，避免无依据重建。
3. 对变更说明停机影响、备份和回滚办法。
4. 数据库、生产服务、数据卷以及 `down -v` 等破坏性操作必须先征得确认。
5. 不泄露 `.env` 和容器内凭据，不随意暴露管理端口。
6. 中文总结操作、观察到的结果和仍需人工确认的步骤。
