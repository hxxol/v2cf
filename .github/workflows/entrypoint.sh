#!/bin/bash
set -e

echo "[entrypoint] 启动 v2ray..."
v2ray run -c /etc/v2ray/config.json &
V2RAY_PID=$!

# 等待 v2ray 稳定启动
sleep 2

echo "[entrypoint] 启动 cloudflared 隧道，转发到 127.0.0.1:1988 ..."

# 运行 cloudflared 并将流量转发到本地 1988 端口
exec cloudflared tunnel --url http://127.0.0.1:1988 run --token eyJhIjoiOWU0Y2U4YTRhZWQzOTUxN2ZlNTlkNzJmZDI4MjY4OTgiLCJ0IjoiMDc5YzNkOTQtMzgzMi00ZDNhLWE4ZmYtNDEyNTc1OTNiOTc5IiwicyI6Ik5HVmxZemxsWXpJdFlXUXpOeTAwTnpSaUxXSTNNakl0TmpJeU1HSXpOVFU0T0dKbCJ9
