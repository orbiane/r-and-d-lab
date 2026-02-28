# Claude Code 機能デモ集

Claude Code（Anthropic製CLI）の主要機能を体験できるデモスクリプト集です。

## 構成

| ディレクトリ | 内容 |
|------------|------|
| `01-slash-commands/` | スラッシュコマンド一覧と使い方 |
| `02-settings-customization/` | 設定ファイル・CLAUDE.md・キーバインド |
| `03-hooks-automation/` | フック（自動化・バリデーション） |
| `04-mcp-tool-extension/` | MCP サーバーによるツール拡張 |

## 前提条件

```bash
# Claude Code がインストール済みであること
claude --version

# GitHub CLI（/review-pr デモ用）
gh --version
```

## クイックスタート

```bash
# 各デモの README を読む
cat claude-code-demos/01-slash-commands/README.md

# デモスクリプトを実行
bash claude-code-demos/01-slash-commands/demo.sh
```

## 学習の順序

1. **スラッシュコマンド** — まず基本操作を把握
2. **設定カスタマイズ** — 自分の環境に合わせる
3. **フック・自動化** — 繰り返し作業を自動化
4. **MCP 拡張** — 外部サービスと連携
