#!/bin/bash
set -e

REPO_URL="https://github.com/liweisi007/nginx-proxy"

echo "📦 Installing nginx-proxy..."

if [ "$(id -u)" != "0" ]; then
  echo "请使用 root 用户运行"
  exit 1
fi

if command -v apt >/dev/null 2>&1; then
  PM=apt
elif command -v yum >/dev/null 2>&1; then
  PM=yum
else
  echo "不支持的系统"
  exit 1
fi

if [ "$PM" = "apt" ]; then
  apt update -y
  apt install -y nginx curl git certbot python3-certbot-nginx
else
  yum install -y epel-release
  yum install -y nginx curl git certbot python3-certbot-nginx
fi

cd /opt
rm -rf nginx-proxy
git clone $REPO_URL
cd nginx-proxy
chmod +x install.sh nginx-proxy nginx-go

echo "✅ 安装完成"
echo "👉 运行 ./nginx-go 开始使用"
