#!/usr/bin/env bash
# =============================================================================
# validate-command.sh — PreToolUse フック: Bash コマンドバリデーター
# =============================================================================
# 危険なコマンドを検出して Claude がそれを実行するのをブロックします。
# exit 2 を返すとブロック、exit 0 を返すと許可します。
# =============================================================================

set -euo pipefail

INPUT=$(cat)

# デバッグ用（必要なら有効化）
# echo "[validate-command] 入力: $INPUT" >&2

# ツール名を確認（Bash 以外は通過）
TOOL_NAME=$(echo "$INPUT" | jq -r '.tool_name // empty')
if [[ "$TOOL_NAME" != "Bash" ]]; then
  exit 0
fi

# 実行しようとしているコマンドを取得
COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command // empty')

if [[ -z "$COMMAND" ]]; then
  exit 0
fi

# ──────────────────────────────────────────────────────────────────────────────
# ブロックリスト: これらのパターンに一致するコマンドはブロックする
# ──────────────────────────────────────────────────────────────────────────────
BLOCKED_PATTERNS=(
  "rm -rf /"            # ルートディレクトリの削除
  "rm -rf \*"           # ワイルドカード削除
  ":(){ :|:& };:"       # Fork Bomb
  "mkfs\."              # ファイルシステムのフォーマット
  "dd if=.*of=/dev/"    # ディスクへの直接書き込み
  "git push --force"    # 強制プッシュ
  "git push -f"         # 強制プッシュ（省略形）
  "DROP TABLE"          # SQL テーブル削除
  "DROP DATABASE"       # SQL データベース削除
  "chmod -R 777"        # 全ファイルを誰でも書き込み可能に
  "> /dev/sda"          # ディスクの上書き
)

for PATTERN in "${BLOCKED_PATTERNS[@]}"; do
  if echo "$COMMAND" | grep -qiE "$PATTERN"; then
    # 構造化された拒否レスポンスを返す
    jq -n \
      --arg reason "危険なコマンドが検出されました: '$COMMAND' はパターン '$PATTERN' に一致します" \
      '{
        "hookSpecificOutput": {
          "hookEventName": "PreToolUse",
          "permissionDecision": "deny",
          "permissionDecisionReason": $reason
        }
      }'
    echo "[BLOCKED] パターン '$PATTERN' に一致: $COMMAND" >&2
    exit 2
  fi
done

# ──────────────────────────────────────────────────────────────────────────────
# 警告リスト: 実行は許可するが stderr に警告を出す
# ──────────────────────────────────────────────────────────────────────────────
WARN_PATTERNS=(
  "sudo"
  "curl.*\|.*bash"      # curl | bash パイプ
  "wget.*\|.*bash"      # wget | bash パイプ
  "npm publish"
)

for PATTERN in "${WARN_PATTERNS[@]}"; do
  if echo "$COMMAND" | grep -qiE "$PATTERN"; then
    echo "[WARNING] 注意が必要なコマンドです: $COMMAND" >&2
    # exit 0 → 許可（警告のみ）
    break
  fi
done

exit 0
