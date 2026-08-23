# ishome-infra

《是我的家》基础设施仓：Terraform（IaC）、Helm charts、Argo CD apps、网关声明式配置。

> 基线：技术架构方案 §2.7（基建基线）、§三（统一网关层）、§七（开源系统清单）。
> 基建基线：ACK（托管 K8s）+ Argo CD（GitOps）+ Harbor + Terraform；服务发现用 K8s 原生 DNS；**不上** Nacos/Dubbo/Istio/Seata；分布式事务 = 编排补偿（saga）+ outbox。

## 目录

```
terraform/
  modules/       # 可复用模块（vpc、ack、rds-pg、oss、redis…）
  envs/dev/      # dev 环境组合
  envs/prod/     # prod 环境组合
helm/            # 各服务 Helm charts（镜像 tag = git sha）
argocd/          # Argo CD Application 声明（GitOps 唯一入口）
gateway/         # 网关声明式配置（见 gateway/README.md）
```

## 中间件清单（技术架构 §七 定案）

| 系统 | 用途 | 部署要点 |
|---|---|---|
| Temporal（自托管） | 工作流编排 | **双 namespace**：genpipe（批量生成作业）与 design（跨月长周期项目工作流，continue-as-new）隔离 |
| RocketMQ 5（云托管） | **唯一业务事件总线** | 只跑业务语义事件；编排细节留 Temporal，不上总线。延迟消息（超时关单）、事务消息（outbox 配套）为选型理由 |
| Postgres（RDS） | 主存储 | **schema-per-service**：`svc_identity / svc_estate / svc_catalog / svc_content / svc_trade / svc_shelf / svc_channel / svc_design`…禁止跨 schema 外键与 join |
| ClickHouse | 行为/归因分析 | 归因事实表以 PG 为准，CH 只做分析副本 |
| Redis 集群 | 缓存 | |
| OSS + CDN | 媒资 | 公开内容与用户私有产物**分 bucket**（私有走 STS 临时凭证）；图/视频走 CDN 直出不过网关 |
| LiteLLM + Langfuse | 多模型 API 网关 + 逐任务成本追踪 | 单图成本、单项目会话 token 成本是经济账输入变量 |
| RuoYi-Vue-Plus | 管理后台基座 | |
| Meilisearch | 小区/户型搜索 | 索引由 estate-svc 所有，定位为基础设施 |
| PostHog(自托管) + ClickHouse + Metabase | 行为漏斗 + 归因 + BI | 运行时质量信号（"换一张"、确认修正率、投诉回流）落此 |
| OpenTelemetry + SkyWalking 或 Grafana LGTM | 全链路观测 | **二选一待定**（Java 班底 SkyWalking 更顺手） |
| Sentry / Argo CD / Harbor / Terraform / Flyway | 错误监控 / GitOps / 镜像 / IaC / 迁移 | |

## 环境事实（2026-08-22 落地首晚）

- **dev 服务器**：`121.89.85.150`（key `~/codes/dev-0722.pem`）；**ol**：`123.56.253.183`（key `~/codes/ol-0722.pem`）。
- 两台机器上**跑着 aidcp 与 isales 的生产服务**（各自 systemd 服务/目录/端口）。ishome 中间件部署前必须先规划端口与资源隔离，**待 ★ 项（①团队画像 / ② PG / ④ 网关）拍板后执行**。
- **今晚未动服务器**——contracts/backend/aipipe 骨架不需要服务器。
- ★ 工作默认见中控仓《落地假设与拍板清单》：PG、云托管网关。

## 状态

骨架阶段：目录与纪律先行，Terraform 模块与 charts 待 ★ 项拍板后填充。
