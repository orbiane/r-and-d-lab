#!/usr/bin/env bash
# =============================================================================
# session-context.sh — SessionStart フック: コンテキスト注入
# =============================================================================
# セッション開始時に環境情報をClaudeに渡します。
# stdout に出力した内容が Claude のコンテキストに追加されます。
# =============================================================================

set -euo pipefail

INPUT=$(cat)

MATCHER=$(echo "$INPUT" | jq -r '.matcher // empty')
CWD=$(echo "$INPUT" | jq -r '.cwd // "unknown"')

# compact 後の再起動では最低限の情報だけを再注入する
if [[ "$MATCHER" == "compact" ]]; then
  echo "## コンテキスト圧縮後の再起動"
  echo ""
  echo "作業ディレクトリ: $CWD"
  echo "日時: $(date '+%Y-%m-%d %H:%M:%S %Z')"
  if [[ -f "CLAUDE.md" ]]; then
    echo ""
    echo "CLAUDE.md の内容は通常通り参照できます。"
  fi
  exit 0
fi

# ──────────────────────────────────────────────────────────────────────────────
# 通常の startup / resume 時のコンテキスト
# ──────────────────────────────────────────────────────────────────────────────
echo "## セッション開始時の環境情報"
echo ""

# 基本情報
echo "- **日時:** $(date '+%Y-%m-%d %H:%M:%S %Z')"
echo "- **作業ディレクトリ:** $CWD"
echo "- **ホスト名:** $(hostname)"
echo "- **ユーザー:** ${USER:-unknown}"
echo ""

# Git リポジトリ情報
if git rev-parse --is-inside-work-tree &>/dev/null 2>&1; then
  BRANCH=$(git branch --show-current 2>/dev/null || echo "detached HEAD")
  LAST_COMMIT=$(git log -1 --format="%h %s" 2>/dev/null || echo "N/A")
  UNCOMMITTED=$(git status --porcelain 2>/dev/null | wc -l | tr -d ' ')

  echo "### Git 状態"
  echo "- **ブランチ:** $BRANCH"
  echo "- **最新コミット:** $LAST_COMMIT"
  echo "- **未コミットの変更:** ${UNCOMMITTED} ファイル"
  echo ""
fi

# Node.js 環境（存在する場合）
if [[ -f "package.json" ]]; then
  PKG_NAME=$(jq -r '.name // "unknown"' package.json 2>/dev/null || echo "unknown")
  PKG_VERSION=$(jq -r '.version // "unknown"' package.json 2>/dev/null || echo "unknown")
  echo "### Node.js プロジェクト"
  echo "- **パッケージ名:** $PKG_NAME"
  echo "- **バージョン:** $PKG_VERSION"
  if command -v node &>/dev/null; then
    echo "- **Node.js:** $(node --version)"
  fi
  echo ""
fi

# Python 環境（存在する場合）
if [[ -f "pyproject.toml" || -f "requirements.txt" ]]; then
  echo "### Python プロジェクト"
  if command -v python3 &>/dev/null; then
    echo "- **Python:** $(python3 --version)"
  fi
  if [[ -n "${VIRTUAL_ENV:-}" ]]; then
    echo "- **仮想環境:** $VIRTUAL_ENV"
  fi
  echo ""
fi

echo "---"
echo "上記は自動取得した環境情報です。作業を開始してください。"

exit 0
