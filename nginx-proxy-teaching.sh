#!/bin/bash
# =====================================================
# nginx-proxy-teaching.sh
# Simple nginx reverse proxy helper script
# =====================================================

set -e

if [ "$(id -u)" != "0" ]; then
  echo "Please run as root"
  exit 1
fi

if command -v apt >/dev/null 2>&1; then
  PM=apt
elif command -v yum >/dev/null 2>&1; then
  PM=yum
else
  echo "Unsupported system"
  exit 1
fi

install_nginx() {
  if ! command -v nginx >/dev/null 2>&1; then
    if [ "$PM" = "apt" ]; then
      apt update -y
      apt install -y nginx curl certbot python3-certbot-nginx
    else
      yum install -y epel-release
      yum install -y nginx curl certbot python3-certbot-nginx
    fi
  fi
  systemctl enable nginx
  systemctl start nginx
}

add_proxy() {
  read -p "Listen port: " PORT
  read -p "Domain (_ if none): " DOMAIN
  read -p "Proxy target (http://127.0.0.1:8080): " TARGET

  CONF="/etc/nginx/conf.d/proxy_${PORT}.conf"

  cat > "$CONF" <<EOF
server {
    listen $PORT;
    server_name $DOMAIN;

    location / {
        proxy_pass $TARGET;
        proxy_http_version 1.1;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection "upgrade";
    }
}
EOF

  nginx -t && systemctl reload nginx
}

remove_proxy() {
  ls /etc/nginx/conf.d/proxy_*.conf 2>/dev/null || echo "None"
  read -p "Config to delete: " CONF
  rm -f /etc/nginx/conf.d/$CONF
  nginx -t && systemctl reload nginx
}

enable_https() {
  read -p "Domain for HTTPS: " DOMAIN
  certbot --nginx -d "$DOMAIN"
}

uninstall_all() {
  read -p "Type yes to uninstall: " C
  [ "$C" != "yes" ] && exit 0
  systemctl stop nginx 2>/dev/null || true
  rm -f /etc/nginx/conf.d/proxy_*.conf
  rm -f /usr/local/bin/nginx-go
  if [ "$PM" = "apt" ]; then
    apt remove -y nginx nginx-common nginx-core
    apt autoremove -y
  else
    yum remove -y nginx
  fi
}

create_nginx_go() {
cat > /usr/local/bin/nginx-go <<'EOF'
#!/bin/bash
while true; do
  echo "1 status 2 start 3 stop 4 restart 5 test 6 add/del 7 https 9 uninstall 0 exit"
  read -p "> " c
  case $c in
    1) systemctl status nginx ;;
    2) systemctl start nginx ;;
    3) systemctl stop nginx ;;
    4) systemctl restart nginx ;;
    5) nginx -t ;;
    6)
      echo "1 add 2 del"; read s
      [ "$s" = "1" ] && bash /usr/local/bin/nginx-proxy-teaching.sh add
      [ "$s" = "2" ] && bash /usr/local/bin/nginx-proxy-teaching.sh del
      ;;
    7) bash /usr/local/bin/nginx-proxy-teaching.sh https ;;
    9) bash /usr/local/bin/nginx-proxy-teaching.sh uninstall ;;
    0) exit 0 ;;
  esac
done
EOF
chmod +x /usr/local/bin/nginx-go
}

install_nginx
create_nginx_go

case "$1" in
  add) add_proxy ;;
  del) remove_proxy ;;
  https) enable_https ;;
  uninstall) uninstall_all ;;
  *) echo "Ready. Run nginx-go" ;;
esac
