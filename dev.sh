#!/usr/bin/env bash
# 本地预览：杀掉旧进程 → 清空 site/ → 重新构建 → mkdocs serve
set -euo pipefail

ROOT="$(cd "$(dirname "$0")" && pwd)"
VENV_ACTIVATE="/Users/qihaoyu/Documents/builderprac_new/folder1/venv/bin/activate"

if [[ -f "$VENV_ACTIVATE" ]]; then
  # shellcheck source=/dev/null
  source "$VENV_ACTIVATE"
else
  echo "未找到 venv，请先: source ../venv/bin/activate" >&2
  exit 1
fi

cd "$ROOT"

if lsof -ti :8000 >/dev/null 2>&1; then
  echo "→ 停止占用 8000 端口的旧 mkdocs 进程…"
  lsof -ti :8000 | xargs kill -9 2>/dev/null || true
  sleep 0.5
fi

echo "→ 校验配置…"
mkdocs build -q

echo ""
echo "✓ 本地预览: http://127.0.0.1:8000/"
echo "  （mkdocs serve 使用临时目录构建，勿直接打开 site/ 文件夹）"
echo "  改 docs/*.md 保存后应自动刷新；普通 Cmd+R 即可，仍旧则用 Cmd+Shift+R"
echo "  勿用 github.io 审阅未 push 的修改"
echo ""

# 必须显式 --livereload：当前 MkDocs CLI 默认 livereload=False，否则改 md 不重建、Cmd+R 仍是旧页
exec mkdocs serve --dev-addr 127.0.0.1:8000 --livereload
