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

### 4.1 本仓库采用的方式：Actions 构建 + 推送到 `gh-pages` 分支

仓库根目录有 [`.github/workflows/deploy.yml`](.github/workflows/deploy.yml)：每次你向 **`main`** 分支 **push** 后，会在云端 `mkdocs build`，再用 [peaceiris/actions-gh-pages](https://github.com/peaceiris/actions-gh-pages) 把 **`site/`** 推到 **`gh-pages` 分支**（仅含静态网页，与源码 `main` 分离）。

**为什么不用「只选 GitHub Actions 作为 Pages 源」的 artifact 部署？**  
那种方式需在 Settings 里**精确**选 *GitHub Actions*；若误留成 *Deploy from a branch → main / (root)*，**`main` 根目录没有 `index.html`**（Markdown 在 `docs/` 里），对外就会一直 **404**。推送到 **`gh-pages`** 并在 Pages 里选该分支，行为更直观。

**首次启用（务必做一次）**

1. 先 **push 一次 `main`**，等 **[Actions](https://github.com/andyqi1223212/andyqi1223212.github.io/actions)** 里 **`deploy` 绿勾**（会自动创建 `gh-pages` 分支）。
2. 打开仓库 **Settings → Pages**。
3. **Build and deployment → Source** 选 **Deploy from a branch**。
4. **Branch** 选 **`gh-pages`**，文件夹选 **`/ (root)`**，保存。

**与「你在 Chrome 登录 GitHub」无关，但必须开的仓库权限（否则可能推不上 `gh-pages`）**

- 打开 **Settings → Actions → General**。
- 滚到 **Workflow permissions**。
- 选中 **Read and write permissions**（不要选只读的 *Read repository contents*），保存。

这样 `GITHUB_TOKEN` 才能在 workflow 里执行 **peaceiris** 的推送。若此处为只读，常见现象是 **Build 成功、Deploy/Push 失败**；个别环境下整条 job 也会报错。

**日常更新（不必本地执行 `mkdocs gh-deploy`）**

```bash
cd /path/to/my-website
git add .
git commit -m "[Cursor] 更新说明"
git push origin main
```

等待约 1～3 分钟，再打开 **`https://你的用户名.github.io/`**。

**用户主页仓库的网址**：仓库名为 `你的用户名.github.io` 时，站点地址为：

`https://你的用户名.github.io/`

（无子路径；示例：[https://andyqi1223212.github.io/](https://andyqi1223212.github.io/)）

### 4.2 若你曾把 Pages 设成「GitHub Actions」源

可以继续保持；但**与当前 workflow（推 `gh-pages`）二选一即可**。若改用本仓库新 workflow，请把 Pages **改回** *Deploy from a branch → gh-pages*，否则仍可能 404 或两套源混淆。

### 4.3 本地 `mkdocs gh-deploy`（可选）

与 CI 同理，也是往 `gh-pages` 推构建结果；日常只 push `main` 让 Actions 跑即可，无需重复。

### 4.4 首次从零创建仓库并推送（备忘）

```bash
cd /path/to/my-website
git init
git add .
git commit -m "initial site"
git remote add origin https://github.com/你的用户名/仓库名.git
git branch -M main
git push -u origin main
```

若推送含 `.github/workflows/` 下的文件，使用 **HTTPS + Personal Access Token** 时，令牌需同时勾选 **`repo`** 与 **`workflow`** 权限，否则会被拒绝。

---

## 五、上线后：在哪里看网站 & GitHub 各入口是什么意思

### 5.1 在网上打开你的网站

- 在浏览器地址栏输入：**`https://andyqi1223212.github.io/`**（将用户名换成你的 GitHub 用户名时，规则相同：`https://<用户名>.github.io/`）。
- 若刚 push 完仍是旧版：**硬刷新**（Mac：`Cmd + Shift + R`）或等 1～2 分钟再试（CDN/浏览器缓存）。
- 想确认是否已发布成功：打开仓库 **[Actions](https://github.com/andyqi1223212/andyqi1223212.github.io/actions)**，最新一次 **deploy** 应为绿色成功。

### 5.2 GitHub 仓库页上常见入口（结合本站点）

| 入口 | 含义（白话） |
|------|----------------|
| **Code（代码）** | 你在网上的「源码柜」：`docs/` 里的 Markdown、`mkdocs.yml`、工作流文件等都在这里；和本机文件夹内容对应（以最新 push 为准）。 |
| **Commits（提交历史）** | 每一次 `git commit` 的记录；可回看「哪天改了什么」。 |
| **Actions** | **自动干活**：本仓库里会跑 **deploy**（构建 MkDocs + 部署到 Pages）。push 后先看这里是否绿勾；红了点进去看日志排错。 |
| **Settings → Pages** | **网站从哪一坨文件发布**：本仓库应设为 **Deploy from a branch** → **`gh-pages`** → **`/ (root)`**（见第四节）。 |
| **Issues / Pull Requests** | 单人维护可少用；多人协作或给自己记待办时可用。 |

**和本地的关系**：本机 `my-website` 是「工作副本」；**GitHub 上的 `main` 是源码**。别人在浏览器里看到的站点，来自 **`gh-pages` 分支上的静态文件**（由 Actions 从 `main` 构建后写入），不是直接打开 `.md`。

### 5.3 推荐维护循环（以后都这么干）

1. **改内容**：只改 `docs/`、`mkdocs.yml`、图片等（不要手改 `site/`）。
2. **本地看效果**：`mkdocs serve`，浏览器打开 <http://127.0.0.1:8000>。
3. **提交并上传**：`git add` → `git commit` → `git push origin main`。
4. **确认上线**：Actions 成功 → 打开 `https://你的用户名.github.io/` 检查。

---

## 六、常见问题

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

### Q: `git push` 提示不允许更新 workflow / 需要 workflow 权限？
- 使用 **HTTPS + PAT** 时，令牌除 **`repo`** 外还需勾选 **`workflow`**，否则不能推送 `.github/workflows/` 下文件。或改用 **SSH** 推送。

### Q: `RPC failed` / `HTTP 400` 推送中断？
- 可尝试：`git config --global http.postBuffer 524288000`，以及 `git config --global http.version HTTP/1.1` 后重试；仍失败可换网络或改用 SSH。

### Q: 线上还是旧页面？
- 先看 **Actions** 是否已成功；再等 1～2 分钟并 **强制刷新** 浏览器。

### Q: Actions 里「Build site」失败，是我账号权限不够吗？
- **一般不是**「登录权限」问题：`mkdocs build` 在 GitHub 提供的 runner 上跑，不读你本机文件。常见原因是 **MkDocs 校验/插件**（本仓库已放宽 `validation`、并暂时关闭 **glightbox** 以保证 CI 稳定）。请点开失败 job，展开 **Build site**，看日志最后几十行英文报错。
- 若 **Build 绿、Push 失败**，再检查上一节 **Workflow permissions** 是否已为 **Read and write**。

### Q: `https://用户名.github.io/` 一直 404？
1. **Settings → Pages** 是否已选 **Deploy from a branch** → **`gh-pages`** → **`/ (root)`**？若仍是 **main** 根目录，必 404（`main` 没有站点根 `index.html`）。
2. **Actions** 里 `deploy` 是否成功？失败时点进日志看报错。
3. 第一次部署前 **`gh-pages` 尚不存在**：先等一次成功的 `deploy` workflow，再回 Pages 下拉框里选 `gh-pages`。

---

## 七、后续可扩展

- **添加交互 Demo**：在仓库加子目录部署前端项目，MD 里写链接即可
- **搜索优化**：已内置全文搜索（支持中文）
- **评论系统**：可集成 Giscus（基于 GitHub Discussions）
- **自定义域名**：在 GitHub Pages 设置里绑定
