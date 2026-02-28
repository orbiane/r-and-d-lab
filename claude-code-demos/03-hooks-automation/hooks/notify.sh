#!/usr/bin/env bash
# =============================================================================
# notify.sh — Notification フック: デスクトップ通知
# =============================================================================
# Claude が入力待ちになったときにデスクトップ通知を送ります。
# 長時間の作業中や別の作業をしているときに便利です。
# =============================================================================

set -euo pipefail

INPUT=$(cat)

MATCHER=$(echo "$INPUT" | jq -r '.matcher // empty')
SESSION_ID=$(echo "$INPUT" | jq -r '.session_id // "unknown"' | cut -c1-8)

# ──────────────────────────────────────────────────────────────────────────────
# 通知メッセージをマッチャーに応じて変える
# ──────────────────────────────────────────────────────────────────────────────
case "$MATCHER" in
  permission_prompt)
    TITLE="Claude Code — 権限確認"
    MESSAGE="[$SESSION_ID] 実行許可の確認が必要です"
    URGENCY="critical"
    ;;
  idle_prompt)
    TITLE="Claude Code — 完了"
    MESSAGE="[$SESSION_ID] 応答完了。入力待ちです"
    URGENCY="normal"
    ;;
  *)
    TITLE="Claude Code"
    MESSAGE="[$SESSION_ID] 入力待ちです"
    URGENCY="low"
    ;;
esac

# ──────────────────────────────────────────────────────────────────────────────
# OS に応じた通知コマンドを選択
# ──────────────────────────────────────────────────────────────────────────────
if [[ "$OSTYPE" == "darwin"* ]]; then
  # macOS
  osascript -e "display notification \"$MESSAGE\" with title \"$TITLE\"" 2>/dev/null || true

elif command -v notify-send &>/dev/null; then
  # Linux (libnotify)
  notify-send --urgency="$URGENCY" --icon="dialog-information" "$TITLE" "$MESSAGE" 2>/dev/null || true

elif command -v powershell.exe &>/dev/null; then
  # Windows / WSL
  powershell.exe -Command "
    Add-Type -AssemblyName System.Windows.Forms
    \$notify = New-Object System.Windows.Forms.NotifyIcon
    \$notify.Icon = [System.Drawing.SystemIcons]::Information
    \$notify.Visible = \$true
    \$notify.ShowBalloonTip(5000, '$TITLE', '$MESSAGE', [System.Windows.Forms.ToolTipIcon]::Info)
  " 2>/dev/null || true

else
  # フォールバック: ターミナルベルを鳴らす
  echo -e "\a" 2>/dev/null || true
  echo "[notify] $TITLE: $MESSAGE" >&2
fi

exit 0
