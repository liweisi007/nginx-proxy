#!/bin/bash
set -e

REPO_RAW="https://raw.githubusercontent.com/liweisi007/nginx-proxy/main"
INSTALL_PATH="/usr/local/bin/nginx-proxy"

echo "nginx-proxy installer"

if [ "$(id -u)" != "0" ]; then
  echo "请使用 root 用户运行"
  exit 1
fi

if ! command -v curl >/dev/null 2>&1; then
  echo "请先安装 curl"
  exit 1
fi

curl -fsSL "$REPO_RAW/nginx-proxy.sh" -o "$INSTALL_PATH"
chmod +x "$INSTALL_PATH"

echo "安装完成，运行 nginx-proxy 开始使用"