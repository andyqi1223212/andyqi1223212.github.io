# 个人网站 — 用户操作手册

## 一、项目概览

这是一个基于 **MkDocs + Material** 主题的 Markdown 驱动个人网站。

**核心理念**：你只需要编辑 Markdown 文件，网站会自动渲染成现代深色风格页面。

### 目录结构

```
my-website/
├── mkdocs.yml              ← 站点配置（导航、主题、插件）
├── docs/                   ← 所有网站内容都在这里
│   ├── index.md            ← 首页
│   ├── about.md            ← 关于我
│   ├── assets/
│   │   ├── extra.css       ← 自定义样式
│   │   └── images/         ← 全站通用图片（头像等）
│   └── projects/
│       ├── index.md        ← 项目总览页
│       ├── anr-optimization.md
│       ├── growth-accounting.md
│       ├── ad-channel-analysis.md
│       └── assets/         ← 项目专用图片
└── site/                   ← 构建产物（自动生成，不要手动改）
```

---

## 二、日常操作

### 2.1 本地预览

```bash
# 1. 激活 Python 环境
source /Users/qihaoyu/Documents/builderprac_new/folder1/venv/bin/activate

# 2. 进入网站目录
cd /Users/qihaoyu/Documents/builderprac_new/folder1/my-website

# 3. 启动预览服务（支持热更新，改文件后浏览器自动刷新）
mkdocs serve
```

打开浏览器访问 **http://127.0.0.1:8000** 即可预览。

按 `Ctrl+C` 停止服务。

### 2.2 更新现有项目内容

直接编辑 `docs/projects/` 下对应的 `.md` 文件即可。预览服务开着的话会自动刷新。

### 2.3 新增一个项目

**第 1 步**：在 `docs/projects/` 下新建 `.md` 文件，例如 `new-project.md`

```markdown
# 项目标题

## 背景

描述问题背景...

## 方法

你怎么做的...

## 代码

​```python
print("用三个反引号 + 语言名包裹代码")
​```

## 结论

结果和反思...
```

**第 2 步**：在 `mkdocs.yml` 的 `nav` 部分添加一行：

```yaml
nav:
  - 首页: index.md
  - 项目经历:
      - 总览: projects/index.md
      - ANR 性能优化与实验设计: projects/anr-optimization.md
      - Growth Accounting Framework: projects/growth-accounting.md
      - 广告渠道特征分析: projects/ad-channel-analysis.md
      - 新项目标题: projects/new-project.md    # ← 加这一行
  - 关于我: about.md
```

**第 3 步**（可选）：在 `docs/projects/index.md` 和 `docs/index.md` 的精选项目区域中也加上新项目的卡片。

### 2.4 添加图片

1. 把图片放到 `docs/projects/assets/` 目录（项目图片）或 `docs/assets/images/` 目录（通用图片如头像）
2. 在 Markdown 中用**相对路径**引用：

```markdown
<!-- 项目页面引用项目图片 -->
![描述](assets/my-image.png)

<!-- 首页引用通用图片 -->
![头像](assets/images/avatar.png)
```

**命名建议**：用英文短横线命名，如 `growth-chart.png`，避免中文和空格。

### 2.5 更新个人信息

- **首页**：编辑 `docs/index.md`（名字、一句话介绍、技能表格）
- **关于我**：编辑 `docs/about.md`（实习经历、教育背景、联系方式）
- **站点标题**：编辑 `mkdocs.yml` 的 `site_name` 字段

### 2.6 添加头像

1. 把头像图片放到 `docs/assets/images/avatar.png`
2. 在 `docs/index.md` 的 hero 区域添加：

```markdown
![头像](assets/images/avatar.png){ width="150", style="border-radius: 50%" }
```

### 2.7 Material 图标（`:material-xxx:`）

站点已在 `mkdocs.yml` 中启用 `pymdownx.emoji`，并指向 Material 自带的图标索引。写法：

```markdown
:material-home:
:material-arrow-right:
:material-chart-timeline-variant:
```

图标名可在 [Material Design Icons](https://pictogrammers.com/library/mdi/) 查找，把下划线换成短横线，并加 `material-` 前缀（例如图标名为 `cellphone-cog` 则写 `:material-cellphone-cog:`）。

若浏览器里仍显示成一串英文，说明扩展未启用或 YAML 缩进错误，请对照仓库里的 `mkdocs.yml` 中 `pymdownx.emoji` 段。

**稳定锚点（可选）**：标题若以数字开头，自动生成的目录锚点可能不好读。可在标题行末尾加 `{#自定义id}`（需已启用 `attr_list`），例如：`### 某标题 {#project-ad-channel}`。

---

## 三、Markdown 常用语法速查

| 需求 | 写法 |
|------|------|
| 标题 | `# 一级` `## 二级` `### 三级` |
| 粗体 | `**粗体文字**` |
| 链接 | `[文字](https://url)` |
| 图片 | `![描述](路径)` |
| 代码块 | 三个反引号 + 语言名（sql、python 等） |
| 表格 | 见现有 `.md` 文件中的示例 |
| Material 图标 | `:material-图标名:`（见上文 2.7） |
| 标题自定义 id | `### 标题 {#my-id}` |
| 提示框 | `!!! tip "标题"` 换行缩进写内容 |
| 警告框 | `!!! warning "标题"` 换行缩进写内容 |
| 信息框 | `!!! info "标题"` 换行缩进写内容 |

---

## 四、部署到互联网（GitHub Pages）

当你准备把网站发布到线上时：

```bash
# 1. 在 GitHub 创建仓库（比如 username.github.io 或 my-portfolio）

# 2. 在 my-website 目录初始化 git
cd /Users/qihaoyu/Documents/builderprac_new/folder1/my-website
git init
git add .
git commit -m "initial site"

# 3. 关联远程仓库
git remote add origin https://github.com/你的用户名/仓库名.git
git push -u origin main

# 4. 一键部署到 GitHub Pages
mkdocs gh-deploy
```

之后每次更新内容：

```bash
git add .
git commit -m "更新了xxx项目"
git push
mkdocs gh-deploy
```

网站地址：`https://你的用户名.github.io/仓库名/`

---

## 五、常见问题

### Q: 图片不显示？
- 检查路径是否为**相对路径**（不要用 `/Users/...` 这种绝对路径）
- 检查文件名大小写是否一致
- 检查图片是否确实在 `docs/` 目录内

### Q: 代码没有高亮？
- 确保用三个反引号包裹，且指定了语言：\```sql、\```python 等

### Q: 新页面加了但导航没显示？
- 检查 `mkdocs.yml` 的 `nav` 是否添加了对应条目
- YAML 格式注意**缩进用空格**，不要用 Tab

### Q: 想改颜色/字体？
- 编辑 `docs/assets/extra.css`
- 主色调在 `mkdocs.yml` 的 `palette.primary` 和 `palette.accent`

### Q: 标题后面出现奇怪的「¶」符号？
- 已默认关闭（`mkdocs.yml` 里 `toc.permalink: false`）。若你需要段首锚点链接，可改回 `permalink: true`，或改用标题行 `{#id}` 手动指定 id 后用 `页面url#id` 分享。

### Q: `:material-xxx:` 显示成英文而不是图标？
- 确认 `mkdocs.yml` 的 `markdown_extensions` 里包含 `pymdownx.emoji` 且 `emoji_index` / `emoji_generator` 两行与仓库示例一致；改完后重新 `mkdocs serve`。

---

## 六、后续可扩展

- **添加交互 Demo**：在仓库加子目录部署前端项目，MD 里写链接即可
- **搜索优化**：已内置全文搜索（支持中文）
- **评论系统**：可集成 Giscus（基于 GitHub Discussions）
- **自定义域名**：在 GitHub Pages 设置里绑定
