# 项目调整记录

> 原始项目：`C:\Users\Administrator\Downloads\归档`（AI Agent 书籍 Markdown 文件）
> 最终产物：MkDocs Material 静态网站 + Docker 镜像 + GitHub Pages 部署

---

## 1. 项目结构摸底

```bash
# 排除 __MACOSX，只看有效文件
find . -name '*.md' | grep -v __MACOSX | sort
```

原始结构（56 个 md + 大量图片）：

| 目录 | 内容 | 文件数 |
|------|------|--------|
| `第一章/` | NLP 基础概念 → Transformer → 预训练 → LLM | 4 |
| `第二章/` | 提示工程（readme 总览 + 9 章） | 10 |
| `第五章/` | RAG 检索增强生成（18 节 + 附录） | 19 |
| `第六章/` | Agent 智能体（11 章中文 + 11 章英文） | 22 |
| `第八章/` | 本地模型部署（Ollama → vLLM） | 1 |

---

## 2. 选型：MkDocs + Material 主题

**为什么选它：**
- Python 生态，`pip install mkdocs mkdocs-material` 即装即用
- 中文搜索原生支持（配置 `lang: zh`）
- 明暗主题切换、响应式布局
- 已在本地 Python 环境预装（v1.6.1 + Material 9.7.7）

**备选方案对比：**

| 方案 | 理由 |
|------|------|
| VitePress | 需要 Node.js，相对重 |
| Docusaurus | React 生态，部署复杂度高 |
| Docsify | 纯客户端渲染，SEO 差 |
| mdBook | 需额外装 Rust，中文支持弱 |

---

## 3. 搭建步骤

### 3.1 复制清洁文件

```bash
# 排除 macOS 资源文件和 __MACOSX 目录
rsync -av --exclude='__MACOSX' --exclude='.DS_Store' --exclude='._*' \
  "/c/Users/Administrator/Downloads/归档/" \
  /c/home/dministrator/agent-book-site/docs/
```

### 3.2 创建 mkdocs.yml

关键配置点：

```yaml
theme:
  name: material
  language: zh           # 中文界面
  features:
    - navigation.sections    # 侧边栏分组（可折叠）
    # 不用 navigation.expand  # 默认全部收起
    - navigation.tracking    # 当前页面高亮
    - search.suggest         # 搜索建议
    - search.highlight       # 搜索结果高亮
    - content.code.copy      # 代码块复制按钮

plugins:
  - search:
      lang: zh               # 中文分词搜索
```

### 3.3 导航结构调整策略

**原则：**
- 每个"部分"是顶级分组，默认折叠
- 子项统一用 `部分号.序号` 格式编号（如 `3.1`, `4.1`）
- 附录特殊标记（如 `附.`）

**调整过程：**
1. 初版：直接用文件标题，导致"第六章"下面又有"第一章"，层级混乱
2. 二版：去掉子项的"第X章"前缀，改为纯序号 + 简短标题
3. 三版：统一为 `[部分号].[序号]` 格式，全部从 `.1` 开始

```yaml
# 最终效果
nav:
  - 第一部分 NLP 基础:
    - 1.1 NLP基础概念
    - 1.2 Transformer架构
    ...
  - 第三部分 RAG:
    - 3.1 RAG 简介
    - 3.2 准备工作
    ...
    - 附. Python虚拟环境
```

### 3.4 构建 & 预览

```bash
mkdocs build    # 构建到 site/
mkdocs serve    # 开发预览 http://localhost:8000
```

---

## 4. Docker 镜像

### 4.1 遇到的坑

**坑1：Docker 代理阻断**

Docker Desktop 配了 `127.0.0.1:7897` 代理但未启动，导致：
- 无法 `docker pull` 任何镜像
- 无法 `apt-get` 安装软件

**临时方案：** 用本地已有的 `nvidia/cuda` 镜像（2.29GB），但没 Python。

**最终方案：** 代理恢复后换 `nginx:alpine`（~10MB），镜像从 8.2GB → 144MB。

### 4.2 最终 Dockerfile

```dockerfile
FROM nginx:alpine
COPY site/ /usr/share/nginx/html/
RUN echo 'server { \
    listen 80; \
    charset utf-8; \
    root /usr/share/nginx/html; \
    location / { try_files $uri $uri/ $uri.html =404; } \
}' > /etc/nginx/conf.d/default.conf
EXPOSE 80
```

### 4.3 构建与导出

```bash
docker build -t agent-book:latest .
docker save agent-book:latest -o agent-book-image.tar  # 140MB
```

---

## 5. GitHub Pages 部署

### 5.1 创建仓库

```bash
# 通过 API 创建（需要 Personal Access Token）
curl -X POST -H "Authorization: token $TOKEN" \
  https://api.github.com/user/repos \
  -d '{"name":"agent-book","private":false}'
```

### 5.2 推送源码 + 部署

```bash
git init
git remote add origin https://github.com/Dinglq123/agent-book.git
git add -A && git commit -m "Initial"
git push -u origin main

# MkDocs 自带 GitHub Pages 部署命令
mkdocs gh-deploy --force
```

`mkdocs gh-deploy` 做的事：构建 site/ → 推到 gh-pages 分支 → GitHub 自动启用 Pages。

### 5.3 启用 Pages

```bash
curl -X POST -H "Authorization: token $TOKEN" \
  https://api.github.com/repos/Dinglq123/agent-book/pages \
  -d '{"source":{"branch":"gh-pages","path":"/"}}'
```

---

## 6. 项目文件清单

```
agent-book-site/
├── README.md           # 使用说明（Docker 启动方式）
├── adjust.md           # 本文件（调整记录）
├── mkdocs.yml          # MkDocs 配置
├── Dockerfile          # Docker 镜像定义
├── .dockerignore       # Docker 构建排除
├── .gitignore          # Git 排除（含 site/）
├── agent-book-image.tar # 镜像导出文件（140MB）
├── docs/               # Markdown 源文件
│   ├── index.md        # 首页
│   ├── 第一章/          # NLP 基础
│   ├── 第二章/          # 提示工程
│   ├── 第五章/          # RAG
│   ├── 第六章/          # Agent
│   └── 第八章/          # 本地部署
└── site/               # 构建产物（gitignore 忽略）
```

---

## 7. 如果再来一次（快速重建）

```bash
# 1. 从原始文件重建
cp -r "C:\Users\Administrator\Downloads\归档" docs/
# 删除 __MACOSX

# 2. 构建网站
mkdocs build

# 3. 构建镜像
docker build -t agent-book:latest .

# 4. 导出镜像
docker save agent-book:latest -o agent-book-image.tar

# 5. 部署到 GitHub Pages
git add -A && git commit -m "update"
git push
mkdocs gh-deploy
```
