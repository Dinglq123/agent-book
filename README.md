# AI Agent 完全指南 — Docker 部署

基于 MkDocs Material 构建的静态文档网站，使用 nginx:alpine 提供 HTTP 服务。

## 📦 镜像信息

| 项目 | 值 |
|------|-----|
| 镜像名 | `agent-book:latest` |
| 大小 | ~144MB（tar 导出约 140MB） |
| Base | nginx:alpine |
| 端口 | 80 |

## 🚀 快速启动

### 方式一：从 tar 导入（离线环境）

```bash
# 导入镜像
docker load -i agent-book-image.tar

# 启动容器
docker run -d --name agent-book -p 8080:80 agent-book:latest

# 访问
# http://localhost:8080
```

### 方式二：从源码构建

```bash
# 构建网站
mkdocs build

# 构建镜像
docker build -t agent-book:latest .

# 启动
docker run -d --name agent-book -p 8080:80 agent-book:latest
```

### 方式三：本地开发预览

```bash
pip install mkdocs mkdocs-material
mkdocs serve
# 访问 http://localhost:8000
```

## 🛠 常用命令

```bash
# 查看容器
docker ps --filter name=agent-book

# 查看日志
docker logs agent-book

# 停止
docker stop agent-book

# 重启
docker restart agent-book

# 删除容器
docker rm -f agent-book
```

## 🌐 在线地址

GitHub Pages: https://dinglq123.github.io/agent-book/
