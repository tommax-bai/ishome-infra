# dev-local：本地开发中间件栈

Temporal + Postgres + Redis，本机 Docker Desktop 一键起。genpipe workflow/worker 联调、Flyway 首批表迁移都对着这套。

## 起停

```bash
cd compose/dev-local
docker compose up -d          # 起（首次会拉镜像；拉不动先 export https_proxy=http://127.0.0.1:7890 http_proxy=$https_proxy）
docker compose ps             # 看状态
docker compose down           # 停（保留数据卷）
docker compose down -v        # 停并清空数据（PG/Redis 数据全没，慎用）
```

compose project 名固定 `ishome-dev`（top-level `name:`），volume/network 均带 `ishome-dev` 前缀，不与本机其它 compose 项目（如 tommax-dev）串。

## 端口表

| 服务 | host 端口 | 容器内 | 说明 |
|---|---|---|---|
| Postgres 16 | **15432** | 5432 | 本机 5432 已被 tommax-dev 占用。user=`ishome`，password 默认 `ishome-local-dev`（可用 `ISHOME_PG_PASSWORD` 覆盖）；库：`ishome`（业务）、`temporal`、`temporal_visibility` |
| Redis 7 | **16379** | 6379 | 本机 6379 已被 tommax-dev 占用 |
| Temporal gRPC | **7233** | 7233 | server 1.29.7（auto-setup），namespace `default` 自动注册 |
| Temporal UI | **8233** | 8080 | http://localhost:8233 |

admin-tools 容器（`ishome-dev-temporal-admin-tools`）常驻，`temporal`/`tctl` CLI 从这里用：

```bash
docker exec ishome-dev-temporal-admin-tools temporal operator namespace describe default
```

## 快速验证

```bash
docker exec ishome-dev-postgres psql -U ishome -c 'select 1'
docker exec ishome-dev-redis redis-cli ping
curl -sf http://localhost:8233 >/dev/null && echo UI OK
```

## 与 LiteLLM 网关（:4000）的关系

互不依赖：LiteLLM 网关是本机 uvx 进程（`litellm/run-dev.sh`，服务 LLM 调用），本栈是容器化中间件（服务 workflow/数据/缓存），各起各的、端口不冲突。

## 备注

- Temporal 持久化用上面 Postgres 的 `temporal` / `temporal_visibility` 两库（initdb 脚本创建，auto-setup 设 `SKIP_DB_CREATE=true` 只做 schema 初始化与 namespace 注册）。
- 起之前如怀疑端口被占：`lsof -iTCP -sTCP:LISTEN -P | grep -E '15432|16379|7233|8233'`（2026-08-23 验证四端口均空闲）。
- dev 服务器变体见 `../dev-server/`（只写了文件，部署由主会话统一执行）。
