# helm

各服务 Helm charts。约定：

- 镜像 tag = git sha（技术架构 §6.5）。
- 服务名 `ishome-{domain}-svc`；K8s namespace 按环境。
- backend/aipipe 各服务模块独立出镜像，chart 与服务一一对应。

占位，待首个服务可部署时填充。
