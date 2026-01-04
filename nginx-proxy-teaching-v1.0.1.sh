#!/bin/bash
# =====================================================
# nginx-proxy-teaching v1.0.1
# 基于 v1.0.0 + kejilion 端口接管思想
# =====================================================

set -e

echo "======================================"
echo "   Nginx 一键反向代理脚本 v1.0.1"
echo "======================================"

# root 检测
if [ "$(id -u)" != "0" ]; then
  echo "❌ 请使用 root 用户运行此脚本"
  exit 1
fi

# 检测系统
if command -v apt >/dev/null 2>&1; then
  PM=apt
elif command -v yum >/dev/null 2>&1; then
  PM=yum
else
  echo "❌ 不支持的系统"
  exit 1
fi

# 安装 nginx
if ! command -v nginx >/dev/null 2>&1; then
  echo "📦 未检测到 Nginx，正在安装..."
  if [ "$PM" = "apt" ]; then
    apt update -y
    apt install -y nginx
  else
    yum install -y epel-release
    yum install -y nginx
  fi
else
  echo "✅ 已安装 Nginx"
fi

# 启动 nginx（若未运行）
if ! pgrep nginx >/dev/null; then
  nginx
fi

echo
echo "1) 新增反向代理"
echo "2) 删除反向代理"
echo "0) 退出"
echo
read -p "请选择操作: " ACTION

# 新增反向代理
if [ "$ACTION" = "1" ]; then
  read -p "请输入监听端口（如 80）: " PORT
  read -p "请输入访问域名（仅用于显示，可填 _ ）: " SERVER_NAME
  read -p "请输入反代目标（如 http://127.0.0.1:8080）: " TARGET

  CONF="/etc/nginx/conf.d/proxy_${PORT}.conf"

  cat > "$CONF" <<EOF
# user_domain: ${SERVER_NAME}
# backend: ${TARGET}

server {
    listen ${PORT} default_server;
    server_name _;

    location / {
        proxy_pass ${TARGET};
        proxy_http_version 1.1;

        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;

        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection "upgrade";
    }
}
EOF

  echo "🔍 正在检测 Nginx 配置..."
  nginx -t

  echo "🔄 重新加载 Nginx..."
  nginx -s reload

  echo
  echo "✅ 反向代理创建完成"
  echo "端口: $PORT"
  echo "域名(显示): $SERVER_NAME"
  echo "后端: $TARGET"
  echo "注意：该端口已被 nginx 完全接管，不再区分域名"
  exit 0
fi

# 删除反向代理
if [ "$ACTION" = "2" ]; then
  echo
  echo "当前反向代理配置："
  echo

  i=1
  declare -A MAP

  for f in /etc/nginx/conf.d/proxy_*.conf; do
    [ -f "$f" ] || continue

    PORT=$(basename "$f" | sed 's/proxy_//;s/.conf//')
    DOMAIN=$(grep '^# user_domain:' "$f" | cut -d':' -f2 | xargs)
    BACKEND=$(grep '^# backend:' "$f" | cut -d':' -f2 | xargs)

    DOMAIN=${DOMAIN:-_}
    BACKEND=${BACKEND:-未知}

    echo "[$i] 端口: $PORT   域名: $DOMAIN   后端: $BACKEND"
    MAP[$i]="$f"
    i=$((i+1))
  done

  if [ "$i" -eq 1 ]; then
    echo "（未找到任何反向代理配置）"
    exit 0
  fi

  echo
  read -p "请输入要删除的序号: " CHOICE

  FILE=${MAP[$CHOICE]}
  if [ -z "$FILE" ]; then
    echo "❌ 无效选择"
    exit 1
  fi

  rm -f "$FILE"
  nginx -t && nginx -s reload

  echo "🗑 已删除反向代理：$FILE"
  exit 0
fi

exit 0