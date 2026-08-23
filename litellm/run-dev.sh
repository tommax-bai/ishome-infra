#!/usr/bin/env bash
# 本地开发用 LiteLLM 网关（:4000）。生产形态为容器部署（infra 阶段），本脚本仅覆盖本机开发。
# 前置：~/.ishome/llm-local.env（DASHSCOPE_API_KEY、LITELLM_MASTER_KEY）；uv 已安装。
set -euo pipefail
cd "$(dirname "$0")"
set -a; source "$HOME/.ishome/llm-local.env"; set +a
export UV_DEFAULT_INDEX="${UV_DEFAULT_INDEX:-https://mirrors.aliyun.com/pypi/simple}"
exec uvx --with 'fastapi==0.115.12' --from 'litellm[proxy]' litellm --config config.yaml --port 4000 --host 127.0.0.1
