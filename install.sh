#!/bin/bash
# =========================================
# nginx-proxy 一键安装脚本
# Repo: https://github.com/liweisi007/nginx-proxy
# =========================================

set -e

REPO_RAW="https://raw.githubusercontent.com/liweisi007/nginx-proxy/main"
INSTALL_PATH="/usr/local/bin/nginx-proxy"

echo "========================================="
echo "🚀 Installing nginx-proxy"
echo "========================================="

# root check
if [ "$(id -u)" != "0" ]; then
  echo "❌ 请使用 root 用户运行"
  exit 1
fi

# 检查 curl
if ! command -v curl >/dev/null 2>&1; then
  echo "❌ 未检测到 curl，请先安装 curl"
  exit 1
fi

echo "⬇️ 下载主脚本..."
curl -fsSL "$REPO_RAW/nginx-proxy-teaching.sh" -o "$INSTALL_PATH"

echo "🔐 设置执行权限..."
chmod +x "$INSTALL_PATH"

echo "⚙️ 初始化 nginx-proxy..."
"$INSTALL_PATH"

echo
echo "========================================="
echo "✅ nginx-proxy 安装完成"
echo
echo "可用命令："
echo "  nginx-proxy    # 初始化 / 主入口"
echo "  nginx-go       # Nginx 管理菜单"
echo "========================================="
