# terraform

IaC 唯一入口。`modules/` 放可复用模块（vpc、ack、rds-pg、oss、redis、clickhouse…），`envs/{dev,prod}` 做环境组合。

- 存储默认 **Postgres（RDS）**（待拍板②工作默认）：schema-per-service，禁止跨 schema 外键与 join。
- 状态后端（OSS backend）与凭证管理待 ★ 项拍板后随首个模块落地。
