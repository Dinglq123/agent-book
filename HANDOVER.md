# 项目交接文档 — AI Agent 完全指南

> 生成时间：2026-07-26  
> 项目路径：`C:\home\dministrator\agent-book-site`  
> GitHub：https://github.com/Dinglq123/agent-book  
> 在线地址：https://dinglq123.github.io/agent-book/

---

## 1. 项目概览

将 Markdown 书籍文件渲染为静态文档网站，支持 Docker 部署和 GitHub Pages 托管。

**当前状态：7 部分，~70 篇文章，150MB Docker 镜像。**

---

## 2. 目录结构

```
C:\home\dministrator\agent-book-site\
├── HANDOVER.md          # 本文件
├── README.md            # Docker 使用说明
├── adjust.md            # 项目调整历史记录
├── mkdocs.yml           # MkDocs 配置（核心文件）
├── Dockerfile           # nginx:alpine 镜像
├── .dockerignore
├── .gitignore
├── agent-book-image.tar # 镜像导出（~150MB，不上传 Git）
├── docs/                # Markdown 源文件（git 跟踪）
│   ├── index.md         # 首页
│   ├── javascripts/
│   │   └── mathjax.js   # LaTeX 公式渲染配置
│   ├── 第一章/          # NLP 基础（4 篇）
│   ├── 第二章/          # 提示工程（10 篇）
│   ├── 第三章/          # 模型调用与 API（9 篇）
│   ├── 第五章/          # RAG（19 篇）
│   ├── 第六章/          # Agent（11 篇中文）
│   ├── 第七章/          # 推理工程（3 篇）🆕
│   └── 第八章/          # 本地部署（1 篇）
└── site/                # 构建产物（gitignore）
```

---

## 3. 核心配置要点

### mkdocs.yml 关键设置

```yaml
theme:
  name: material
  language: zh
  features:
    - navigation.sections    # 侧边栏分组折叠
    # 不要 navigation.expand  # 默认全部收起

markdown_extensions:
  - pymdownx.arithmatex:     # LaTeX 公式
      generic: true

extra_javascript:
  - javascripts/mathjax.js   # MathJax 配置
  - https://cdn.jsdelivr.net/npm/mathjax@3/es5/tex-mml-chtml.js

plugins:
  - search:
      lang: zh               # 中文搜索
```

### 导航编号规范

- 每部分用 `[部分号].[序号]` 格式（如 `3.1`, `4.1`, `7.1`）
- 附录用 `附.` 标记
- 子项不加"第X章"前缀

### 图片路径规范

**所有图片路径必须用 `../imgs/` 前缀**（MkDocs 目录式 URL 兼容）：
```html
<!-- ✅ 正确 -->
<img src="../imgs/3-figures/1757249275674-0.png">

<!-- ❌ 错误（浏览器会解析到错误目录） -->
<img src="imgs/3-figures/1757249275674-0.png">
```

---

## 4. 一键部署命令

```bash
cd C:\home\dministrator\agent-book-site

# 构建网站 + 镜像 + 导出 + 推送 GitHub
mkdocs build && \
docker build -t agent-book:latest . && \
docker rm -f agent-book 2>/dev/null && \
docker run -d --name agent-book -p 8080:80 agent-book:latest && \
docker save agent-book:latest -o agent-book-image.tar && \
git add -A && git commit -m "update" && git push && \
mkdocs gh-deploy --force
```

---

## 5. 添加新章节流程

按之前的思路调整后，添加新内容的步骤：

1. **复制源文件到 `docs/`**
2. **检查图片路径** — 全部用 `../imgs/`，云端图片下载到本地
3. **更新 `mkdocs.yml`** — 在 `nav:` 下添加新部分，编号接续
4. **更新 `docs/index.md`** — 同步概览表
5. **执行一键部署命令**

---

## 6. 历史坑点

| 问题 | 解决方案 |
|------|---------|
| Docker 代理 `127.0.0.1:7897` 阻断 | 代理恢复后换 `nginx:alpine` |
| 图片不显示 | `imgs/` → `../imgs/`（383 处） |
| 数学公式不渲染 | 加 `pymdownx.arithmatex` + MathJax CDN |
| `mkdocs gh-deploy` 需 force | 用 `--force` 参数 |
| `.gitignore` 排除 tar 和 site/ | 手动维护 |

---

## 7. GitHub 认证

- 用户：`Dinglq123`
- 仓库：`Dinglq123/agent-book`
- Token：见本会话历史记录（已脱敏）
- Remote：`https://Dinglq123:TOKEN@github.com/Dinglq123/agent-book.git`

---

## 8. 原始数据来源

| 版本 | 路径 |
|------|------|
| v1 | `C:\Users\Administrator\Downloads\归档` |
| v2 | `C:\Users\Administrator\Downloads\归档v2` |
| 第七章 | `C:\Users\Administrator\Downloads\大模型学习路线v1\第七章...` |

---

## 9. 后续可做

- [ ] 补充缺失章节（第三、四、九章可能在某处）
- [ ] 中英文版本切换（英文版已在 docs 中但未入导航）
- [ ] GitHub Actions 自动构建部署
- [ ] 内网离线部署（MathJax 下载到本地）
- [ ] SEO 优化（sitemap、meta）
