# nginx-proxy

一个 **轻量、无面板、适配 Docker / VPS / 无 systemd 环境** 的 Nginx 反向代理管理脚本。  
适合个人长期自用，支持一键安装、中文交互、HTTPS、卸载。

---

## ✨ 功能特性

- 一键安装 / 卸载 Nginx
- 反向代理新增 / 删除
- 支持 HTTP / WebSocket
- 一键启用 HTTPS（Let's Encrypt）
- 中文交互管理菜单（nginx-go）
- 不依赖 systemd（容器环境可用）

---

## 🚀 一键安装

```bash
curl -fsSL https://raw.githubusercontent.com/liweisi007/nginx-proxy/main/install.sh | bash
```

安装完成后可用命令：

```bash
nginx-go        # 进入中文管理菜单
nginx-proxy     # 主脚本（命令行方式）
```

---

## 🧭 常用操作

### 启动管理菜单
```bash
nginx-go
```

### 新增反向代理
```bash
nginx-proxy add
```

示例：
- 监听端口：80
- 域名：_
- 反代目标：http://127.0.0.1:8080

---

### 删除反向代理
```bash
nginx-proxy del
```

---

### 启用 HTTPS
> 需要域名已解析到服务器 IP

```bash
nginx-proxy https
```

---

### 卸载
```bash
nginx-proxy uninstall
```

---

## 📂 文件结构说明

```
install.sh      # 一键安装入口
nginx-proxy     # 主脚本（唯一真源）
nginx-go        # 中文交互管理菜单
```

---

## 🔒 HTTPS 证书续期（推荐）

Let's Encrypt 证书有效期 90 天，建议添加定时任务：

```bash
crontab -e
```

```cron
0 3 * * * certbot renew --quiet
```

---

## ⚠️ 注意事项

- 请使用 root 用户运行
- 80 / 443 端口需未被防火墙阻挡
- 若 80 端口已被占用，请选择其他监听端口

---

## 📜 License

MIT License