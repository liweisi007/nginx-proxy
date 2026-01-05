# nginx-proxy

一个 **轻量级、无面板、纯 Bash 的 Nginx 反向代理管理脚本**，
适合 VPS / 云服务器 / Docker 宿主机 **自用与运维场景**。

> 设计目标：**简单、可控、可维护**  
> 不依赖 Web 面板，不引入额外服务

---

## ✨ 特性

- 🚀 一键创建 Nginx 反向代理
- 🔐 自动申请 & 管理 HTTPS（Certbot）
- 🧩 交互式配置，**无需手写 nginx 配置**
- ⚡ 默认端口与协议自动识别（更少输入）
- 🛠 适配 Debian / Ubuntu / CentOS

---

## 📦 项目结构

```text
.
├── install.sh      # 安装脚本（nginx / certbot）
├── nginx-proxy     # 主脚本（反代 / https 管理）
├── nginx-go        # 快捷菜单入口
└── README.md
```

---

## 🧰 安装

```bash
git clone <你的仓库地址>
cd nginx-proxy
chmod +x install.sh nginx-proxy nginx-go
./install.sh
```

> 请使用 **root 用户** 运行

---

## 🚀 使用方法

### 启动管理菜单

```bash
./nginx-go
```

或直接运行主脚本：

```bash
./nginx-proxy
```

---

## 🔁 添加反向代理（推荐方式）

创建反代时，**只需要输入域名和端口**，其余自动处理。

### 交互示例

```text
监听端口: 80
访问域名(example.com，_ 表示全部): test.example.com
反代目标域名(如 127.0.0.1): 127.0.0.1
反代目标端口(默认 80):
```

### 实际效果

- 自动补全反代地址：

```text
http://127.0.0.1:80
```

- 自动规范化访问地址：

```text
https://test.example.com
```

- 生成的 Nginx 配置：

```nginx
server {
    listen 80;
    server_name test.example.com;

    location / {
        proxy_pass http://127.0.0.1:80;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
```

---

## 🔐 HTTPS 管理

脚本集成 **Certbot**，支持：

- 自动申请 HTTPS 证书
- 自动配置 Nginx
- 证书续期由系统 cron / timer 处理

> HTTPS 申请要求域名已正确解析到服务器 IP

---

## 🗑 删除反向代理

在菜单中选择删除即可：

- 删除 Nginx 配置
- 重载 Nginx

不会影响其他站点

---

## ⚠️ 注意事项

- `server_name` **必须是裸域名**
- `_` 表示匹配所有域名
- HTTPS 与 HTTP 监听端口需区分（80 / 443）
- 不建议在同一端口绑定多个不同用途站点

---

## 🎯 适合人群

- 不想用面板的用户
- VPS / 云服务器自部署
- Docker 宿主机反代
- 运维 / DevOps / 后端开发

---

## 📌 设计原则

- 不做面板
- 不做守护进程
- 所有配置 **可读、可追溯**
- 一切基于原生 Nginx

---

## 🤝 贡献

欢迎 PR：

- 功能增强
- 文档完善
- 兼容性改进

> 建议提交 **PR 级别 diff**，方便 review 与合并

---

## 📄 License

MIT
