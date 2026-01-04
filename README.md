# nginx-proxy

一个 **轻量、交互式、端口接管式** Nginx 反向代理辅助脚本。  
适合将 Docker 或本地服务快速反代到指定端口，并可一键启用 HTTPS。

> 灵感来源于 kejilion.sh，强调 **可用性优先、少折腾**。

---

## 特性

- 端口接管式反向代理（一个端口 = 一个后端）
- Docker 友好，不与容器抢端口
- 简单文本交互，无复杂菜单
- 基础 Nginx 管理（状态 / 启动 / 停止）
- HTTPS 自动申请（Certbot）
- 不自杀式卸载，避免脚本异常退出

---

## 一键安装

```bash
curl -fsSL https://raw.githubusercontent.com/liweisi007/nginx-proxy/main/install.sh | bash
```

安装完成后运行：

```bash
nginx-proxy
```

---

## 菜单说明

1. 查看 Nginx 状态  
2. 启动 Nginx  
3. 停止 Nginx  

4. 新建 / 删除反向代理  

5. 查看错误日志  
6. 卸载 nginx-proxy  
0. 退出  

---

## 反向代理示例（Docker WebSSH）

假设容器监听 8888：

- 监听端口：80  
- 后端地址：http://127.0.0.1:8888  
- 域名：webssh.example.com  

访问：

```
http://webssh.example.com
```

---

## HTTPS

当端口为 80 且填写域名时，可自动启用 HTTPS：

```bash
certbot --nginx -d your-domain.com
```

---

## 卸载

菜单选择「卸载 nginx-proxy」将清理反代配置。  
如需删除脚本本身：

```bash
rm -f /usr/local/bin/nginx-proxy
```

---

## License

MIT