#!/bin/bash
set -e

# 校验 Cloudflare Tunnel Token 是否存在
if [ -z "$CF_TUNNEL_TOKEN" ]; then
  echo "[entrypoint] ERROR: CF_TUNNEL_TOKEN environment variable is not set"
  exit 1
fi

echo "[entrypoint] 启动 v2ray..."
v2ray run -c /etc/v2ray/config.json &
V2RAY_PID=$!

# 等待 v2ray 稳定启动
sleep 2

echo "[entrypoint] 启动 cloudflared 隧道，转发到 127.0.0.1:1988 ..."

# 运行 cloudflared 并将流量转发到本地 1988 端口
exec cloudflared tunnel \
  --url tcp://127.0.0.1:1988 \
  run \
  --token "$CF_TUNNEL_TOKEN"
