# 项目交接文档 — AI Agent 完全指南

> 更新时间：2026-07-26
> 项目路径：`C:\home\dministrator\agent-book-site`
> GitHub：https://github.com/Dinglq123/agent-book
> 在线地址：https://dinglq123.github.io/agent-book/


## 1. 项目概览

将 Markdown 书籍文件渲染为静态文档网站，支持 Docker 部署、GitHub Pages 托管和 PDF 导出。

当前状态：7 部分，~70 篇文章，150MB Docker 镜像，7 个分章 PDF。


## 2. 目录结构

```
C:\home\dministrator\agent-book-site\
├── HANDOVER.md              # 本文件
├── README.md                # Docker 使用说明
├── adjust.md                # 项目调整历史记录
├── mkdocs.yml               # MkDocs 配置（核心文件）
├── Dockerfile               # nginx:alpine 镜像
├── .dockerignore
├── .gitignore
├── agent-book-image.tar     # 镜像导出（~150MB，不上传 Git）
├── generate_pdf.py          # PDF 生成脚本
├── 大模型热门教程推荐.html   # 学习资源推荐网页
├── 大模型热门教程推荐.txt   # 学习资源推荐纯文本
├── AI-Agent完全指南.pdf     # 旧版合并 PDF（107MB）
├── docs/                    # Markdown 源文件（git 跟踪）
│   ├── index.md             # 首页
│   ├── javascripts/
│   │   └── mathjax.js       # LaTeX 公式渲染配置
│   ├── 第一章/              # NLP 基础（4 篇）
│   ├── 第二章/              # 提示工程（10 篇）
│   ├── 第三章/              # 模型调用与 API（9 篇）
│   ├── 第五章/              # RAG（19 篇）
│   ├── 第六章/              # Agent（11 篇中文）
│   ├── 第七章/              # 推理工程（3 篇）
│   └── 第八章/              # 本地部署（1 篇）
├── pdf/                     # PDF 输出目录
│   ├── 01-NLP基础.pdf       (6MB)
│   ├── 02-提示工程.pdf       (5MB, 92页)
│   ├── 03-模型调用与API.pdf  (3MB, 81页)
│   ├── 04-RAG检索增强生成.pdf(33MB, 157页)
│   ├── 05-智能体Agent.pdf   (54MB, 442页)
│   ├── 06-本地模型部署.pdf   (3MB, 34页)
│   ├── 07-大模型推理工程.pdf (2MB, 46页)
│   └── Dify-Workflow101-全10课.pdf (19MB, 92页)
└── site/                    # 构建产物（gitignore）
```


## 3. 核心配置要点

### mkdocs.yml 关键设置

- 主题: material, language: zh
- 侧边栏: navigation.sections（不要 navigation.expand）
- 公式: pymdownx.arithmatex + MathJax CDN
- 搜索: lang: zh（中文分词）

### 导航编号规范

- 每部分用 `[部分号].[序号]` 格式（如 3.1, 4.1, 7.1）
- 附录用 `附.` 标记
- 子项不加"第X章"前缀

### 图片路径规范

所有图片路径必须用 `../imgs/` 前缀（MkDocs 目录式 URL 兼容）：
- 正确: `<img src="../imgs/3-figures/xxx.png">`
- 错误: `<img src="imgs/3-figures/xxx.png">`


## 4. 一键部署命令

```bash
cd C:\home\dministrator\agent-book-site
mkdocs build && \
docker build -t agent-book:latest . && \
docker rm -f agent-book 2>/dev/null && \
docker run -d --name agent-book -p 8080:80 agent-book:latest && \
docker save agent-book:latest -o agent-book-image.tar && \
git add -A && git commit -m "update" && git push && \
mkdocs gh-deploy --force
```


## 5. PDF 生成

### 工具

Playwright + Chromium，脚本：`generate_pdf.py`

### 生成命令

```bash
cd C:\home\dministrator\agent-book-site
python generate_pdf.py
```

### 输出

分 7 个部分，每个部分独立 PDF，带书签，编号前缀排序（01- ~ 07-）。

### 外部页面转 PDF

```bash
python -c "
from playwright.sync_api import sync_playwright
with sync_playwright() as pw:
    p=pw.chromium.launch(headless=True).new_page()
    p.goto('URL', wait_until='networkidle', timeout=30000)
    p.pdf(path='output.pdf', format='A4', print_background=True)
"
```


## 6. 添加新章节流程

1. 复制源文件到 docs/，删除 __MACOSX
2. 检查图片路径 — 全部用 ../imgs/，云端图片下载到本地
3. 更新 mkdocs.yml — 在 nav: 下添加新部分，编号接续
4. 更新 docs/index.md — 同步概览表
5. 执行一键部署命令


## 7. 历史坑点

- Docker 代理 127.0.0.1:7897 阻断 → 代理恢复后换 nginx:alpine
- 图片不显示 → imgs/ 改为 ../imgs/（383 处）
- 数学公式不渲染 → 加 pymdownx.arithmatex + MathJax CDN
- mkdocs gh-deploy 需 force → 用 --force 参数
- .gitignore 排除 tar 和 site/ → 手动维护
- PDF 脚本输出到 材料汇总/ 而非 pdf/ → 已修复路径


## 8. GitHub 认证

- 用户：Dinglq123
- 仓库：Dinglq123/agent-book
- Token：见本会话历史记录（已脱敏）
- Remote：https://github.com/Dinglq123/agent-book.git


## 9. 原始数据来源

- v1：C:\Users\Administrator\Downloads\归档
- v2：C:\Users\Administrator\Downloads\归档v2
- 第三章补充：归档v2 中含第三章（模型调用与 API）
- 第七章：C:\Users\Administrator\Downloads\大模型学习路线v1\第七章...


## 10. 后续可做

- 补充缺失章节（第三、四、九章可能在某处）
- 中英文版本切换（英文版已在 docs 中但未入导航）
- GitHub Actions 自动构建部署
- 内网离线部署（MathJax 下载到本地）
- SEO 优化（sitemap、meta）
- PDF 封面和目录页
