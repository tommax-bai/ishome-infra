#!/usr/bin/env bash
# 本地开发用 LiteLLM 网关（默认 :4000）。生产形态为容器部署（infra 阶段），本脚本仅覆盖本机开发。
# 前置：~/.ishome/llm-local.env（DASHSCOPE_API_KEY、LITELLM_MASTER_KEY）；uv 已安装。
#
# 端口可传参。改了 config.yaml 要重启网关才认新逻辑名，而 4000 是常驻网关、不该为一次验证被打断
# ——故新逻辑名的真跑一律另起临时端口跑完即停，4000 全程不动（先例：2026-08-29 报告推导步真跑）：
#   ./run-dev.sh 4001
set -euo pipefail
cd "$(dirname "$0")"
PORT="${1:-4000}"
set -a; source "$HOME/.ishome/llm-local.env"; set +a
export UV_DEFAULT_INDEX="${UV_DEFAULT_INDEX:-https://mirrors.aliyun.com/pypi/simple}"
exec uvx --with 'fastapi==0.115.12' --from 'litellm[proxy]' litellm --config config.yaml --port "$PORT" --host 127.0.0.1
