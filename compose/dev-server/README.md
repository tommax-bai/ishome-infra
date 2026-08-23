# dev-server：dev ECS 中间件栈（121.89.85.150）

`dev-local` 的服务器变体，栈与端口完全一致（PG **15432** / Redis **16379** / Temporal **7233** / UI **8233**）。

> **红线：该机同时跑着 aidcp 与 isales 的生产服务，只做加法。**
> 本目录只是部署文件；实际部署由主会话统一执行，勘察结论（端口/资源余量）出来前不得 `up`。

## 与 dev-local 的差异

| 项 | dev-local | dev-server |
|---|---|---|
| 端口绑定 | 0.0.0.0（本机随便连） | **只绑 127.0.0.1**，不对公网暴露；UI 走 SSH 隧道 |
| PG 口令 | compose 内置默认值 | **必须**经 `.env` 注入（`ISHOME_PG_PASSWORD`，无默认值，缺了起不来）；`.env` 不入库，模板 `.env.example` |
| 资源 | 不限 | 各容器 `mem_limit`（PG 1g / Temporal 1g / 其余 256m），不与既有服务抢资源 |

## 部署前检查清单（必须全过才允许 up）

在服务器上执行：

```bash
# 1) 端口空闲（四个都必须无输出）
ss -tlnp | grep -E ':(15432|16379|7233|8233)\b' || echo ports-free
# 2) 资源余量：内存至少余 ~3G、磁盘余量充足（镜像+数据卷约需数 GB）
free -h && df -h /
# 3) docker / docker compose v2 可用
docker compose version
```

任何一项不满足：换端口/扩容/另找机器，并回写本 README 与端口表，**不得挤占 aidcp / isales 资源**。

## 部署与起停（主会话执行）

```bash
cd compose/dev-server
cp .env.example .env && $EDITOR .env   # 填真实口令
docker compose up -d
docker compose ps
docker compose down                     # 保留数据卷
```

## 访问方式

端口全部只绑 127.0.0.1，服务器上的 ishome 服务经 `localhost:15432 / 16379 / 7233` 直连；开发机看 UI 用 SSH 隧道：

```bash
ssh -i ~/codes/dev-0722.pem -L 8233:127.0.0.1:8233 <user>@121.89.85.150
# 然后浏览器开 http://localhost:8233
```

## 验证（同 dev-local）

```bash
docker exec ishome-dev-postgres psql -U ishome -c 'select 1'
docker exec ishome-dev-redis redis-cli ping
docker exec ishome-dev-temporal-admin-tools temporal operator namespace describe default
curl -sf http://127.0.0.1:8233 >/dev/null && echo UI OK
```
