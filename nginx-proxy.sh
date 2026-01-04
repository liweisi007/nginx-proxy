#!/bin/bash
set -e

SELF_PATH="$(readlink -f "$0")"

if [ "$(id -u)" != "0" ]; then
  echo "请使用 root 用户运行"
  exit 1
fi

if ! command -v nginx >/dev/null 2>&1; then
  if command -v apt >/dev/null 2>&1; then
    apt update -y && apt install -y nginx
  elif command -v yum >/dev/null 2>&1; then
    yum install -y epel-release && yum install -y nginx
  else
    echo "不支持的系统"
    exit 1
  fi
fi

while true; do
  clear
  echo "Nginx 管理菜单（端口接管模式）"
  echo "1 查看状态"
  echo "2 启动"
  echo "3 停止"
  echo "4 反向代理管理"
  echo "5 查看错误日志"
  echo "6 卸载 nginx-proxy"
  echo "0 退出"
  read -p "选择: " C

  case "$C" in
    1) pgrep nginx && ps -eo pid,cmd | grep '[n]ginx' || echo "未运行"; read ;;
    2) pgrep nginx || nginx ;;
    3) pgrep nginx && nginx -s quit || echo "未运行" ;;
    4)
      read -p "监听端口(默认80): " PORT
      PORT=${PORT:-80}
      read -p "后端地址: " BACKEND
      read -p "域名(可空): " DOMAIN
      CONF="/etc/nginx/conf.d/proxy_${PORT}.conf"
      cat > "$CONF" <<EOF
server {
  listen ${PORT} default_server;
  server_name ${DOMAIN:-_};
  location / {
    proxy_pass ${BACKEND};
    proxy_http_version 1.1;
    proxy_set_header Host \$host;
    proxy_set_header Upgrade \$http_upgrade;
    proxy_set_header Connection "upgrade";
  }
}
EOF
      nginx -t && nginx -s reload
      ;;
    5) tail -n 50 /var/log/nginx/error.log ;;
    6) rm -f /etc/nginx/conf.d/proxy_*.conf; nginx -s reload; echo "已清理配置";;
    0) exit 0 ;;
  esac
done