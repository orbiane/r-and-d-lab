#!/usr/bin/env bash
# =============================================================================
# auto-format.sh — PostToolUse フック: 自動コードフォーマット
# =============================================================================
# Edit / Write ツール実行後、変更されたファイルを自動フォーマットします。
# Prettier, gofmt, black など、プロジェクトに合わせて設定してください。
# =============================================================================

set -euo pipefail

INPUT=$(cat)

TOOL_NAME=$(echo "$INPUT" | jq -r '.tool_name // empty')

# Edit または Write のみ処理
if [[ "$TOOL_NAME" != "Edit" && "$TOOL_NAME" != "Write" ]]; then
  exit 0
fi

FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // empty')

if [[ -z "$FILE_PATH" || ! -f "$FILE_PATH" ]]; then
  exit 0
fi

# ファイルの拡張子を取得
EXT="${FILE_PATH##*.}"

# ──────────────────────────────────────────────────────────────────────────────
# 拡張子に応じてフォーマッターを選択
# ──────────────────────────────────────────────────────────────────────────────
case "$EXT" in
  # JavaScript / TypeScript / JSON / CSS / HTML / Markdown
  js|jsx|ts|tsx|json|css|scss|html|md|yaml|yml)
    if command -v prettier &>/dev/null; then
      prettier --write "$FILE_PATH" 2>&1 \
        && echo "[auto-format] Prettier 実行: $FILE_PATH" >&2 \
        || echo "[auto-format] Prettier エラー: $FILE_PATH" >&2
    else
      echo "[auto-format] prettier が見つかりません (npm install -g prettier)" >&2
    fi
    ;;

  # Python
  py)
    if command -v black &>/dev/null; then
      black "$FILE_PATH" 2>&1 \
        && echo "[auto-format] Black 実行: $FILE_PATH" >&2 \
        || echo "[auto-format] Black エラー: $FILE_PATH" >&2
    elif command -v ruff &>/dev/null; then
      ruff format "$FILE_PATH" 2>&1 \
        && echo "[auto-format] Ruff 実行: $FILE_PATH" >&2
    else
      echo "[auto-format] black / ruff が見つかりません" >&2
    fi
    ;;

  # Go
  go)
    if command -v gofmt &>/dev/null; then
      gofmt -w "$FILE_PATH" 2>&1 \
        && echo "[auto-format] gofmt 実行: $FILE_PATH" >&2
    fi
    ;;

  # Rust
  rs)
    if command -v rustfmt &>/dev/null; then
      rustfmt "$FILE_PATH" 2>&1 \
        && echo "[auto-format] rustfmt 実行: $FILE_PATH" >&2
    fi
    ;;

  # Shell scripts
  sh|bash)
    if command -v shfmt &>/dev/null; then
      shfmt -w "$FILE_PATH" 2>&1 \
        && echo "[auto-format] shfmt 実行: $FILE_PATH" >&2
    fi
    ;;

  *)
    # 対応フォーマッターなし — 何もしない
    ;;
esac

# PostToolUse フックは exit 0 を返せば OK（ブロック機能はない）
exit 0
