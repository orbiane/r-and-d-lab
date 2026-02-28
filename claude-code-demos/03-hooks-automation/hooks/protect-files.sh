#!/usr/bin/env bash
# =============================================================================
# protect-files.sh — PreToolUse フック: 機密ファイル保護
# =============================================================================
# Edit / Write ツールが機密ファイルを変更しようとしたらブロックします。
# =============================================================================

set -euo pipefail

INPUT=$(cat)

TOOL_NAME=$(echo "$INPUT" | jq -r '.tool_name // empty')

# Edit または Write のみ処理
if [[ "$TOOL_NAME" != "Edit" && "$TOOL_NAME" != "Write" ]]; then
  exit 0
fi

FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // empty')

if [[ -z "$FILE_PATH" ]]; then
  exit 0
fi

# ──────────────────────────────────────────────────────────────────────────────
# 保護対象のパターン
# ──────────────────────────────────────────────────────────────────────────────
PROTECTED_PATTERNS=(
  '\.env$'               # .env ファイル
  '\.env\.'              # .env.local, .env.production など
  '\.git/'               # .git ディレクトリ内
  'secrets/'             # secrets ディレクトリ
  'credentials'          # 認証情報ファイル
  '\.pem$'               # SSL 秘密鍵
  '\.key$'               # 秘密鍵
  '\.p12$'               # PKCS12
  'id_rsa'               # SSH 秘密鍵
  'id_ed25519'           # SSH 秘密鍵 (Ed25519)
)

for PATTERN in "${PROTECTED_PATTERNS[@]}"; do
  if echo "$FILE_PATH" | grep -qE "$PATTERN"; then
    jq -n \
      --arg file "$FILE_PATH" \
      --arg pattern "$PATTERN" \
      '{
        "hookSpecificOutput": {
          "hookEventName": "PreToolUse",
          "permissionDecision": "deny",
          "permissionDecisionReason": ("機密ファイルへの書き込みをブロックしました: " + $file)
        }
      }'
    echo "[BLOCKED] 機密ファイルへの書き込み拒否: $FILE_PATH (パターン: $PATTERN)" >&2
    exit 2
  fi
done

exit 0
