#!/bin/bash
# weekly-report.sh — 先週の TIL をまとめて週次レポートを生成する

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"
TIL_DIR="$ROOT_DIR/til"
REPORTS_DIR="$ROOT_DIR/reports"

mkdir -p "$REPORTS_DIR"

# 対象期間（デフォルト：先週月曜〜日曜）
START_DATE="${1:-$(date -d 'last monday' '+%Y-%m-%d')}"
END_DATE="${2:-$(date -d 'last sunday' '+%Y-%m-%d')}"
REPORT_FILE="$REPORTS_DIR/week-of-${START_DATE}.md"

echo "# 週次学習レポート: ${START_DATE} 〜 ${END_DATE}"  > "$REPORT_FILE"
echo ""                                                   >> "$REPORT_FILE"
echo "_生成日: $(date '+%Y-%m-%d')_"                     >> "$REPORT_FILE"
echo ""                                                   >> "$REPORT_FILE"

# TIL ファイルを日付順にまとめる
count=0
for f in "$TIL_DIR"/20*.md; do
  filename=$(basename "$f" .md)
  if [[ "$filename" < "$START_DATE" ]] || [[ "$filename" > "$END_DATE" ]]; then
    continue
  fi
  echo "---"                 >> "$REPORT_FILE"
  echo ""                    >> "$REPORT_FILE"
  cat "$f"                   >> "$REPORT_FILE"
  echo ""                    >> "$REPORT_FILE"
  count=$((count + 1))
done

if [ "$count" -eq 0 ]; then
  echo "（この期間の TIL はありません）" >> "$REPORT_FILE"
fi

echo "✅ レポートを生成しました: $REPORT_FILE（$count 件）"
