# 04 — MCP（Model Context Protocol）ツール拡張

MCP サーバーを使って Claude Code に外部ツール・API・データソースを追加する方法。

---

## MCP とは

MCP（Model Context Protocol）は Claude Code と外部サービスを連携するオープン規格です。
MCP サーバーを追加することで Claude Code が **ツール**（呼び出し可能な関数）と **プロンプト**（スラッシュコマンド）を新たに扱えるようになります。

---

## MCPサーバーの追加方法

### 方法 1: HTTP サーバー（クラウドサービス向け）

```bash
# GitHub MCP（コードレビュー・PR・Issue 操作）
claude mcp add --transport http github https://api.githubcopilot.com/mcp/

# Sentry（エラー監視）
claude mcp add --transport http sentry https://mcp.sentry.dev/mcp

# Notion（ドキュメント）
claude mcp add --transport http notion https://mcp.notion.com/mcp
```

### 方法 2: Stdio サーバー（ローカルプロセス向け）

```bash
# PostgreSQL/MySQL データベース操作
claude mcp add --transport stdio \
  --env POSTGRESQL_URL=postgres://user:pass@localhost:5432/mydb \
  postgres \
  -- npx -y @bytebase/dbhub

# ファイルシステム操作（高度なファイル管理）
claude mcp add --transport stdio filesystem \
  -- npx -y @modelcontextprotocol/server-filesystem /path/to/serve

# 環境変数付きで追加
claude mcp add --transport stdio \
  --env API_KEY=your-api-key \
  --env API_BASE_URL=https://api.example.com \
  my-api-server \
  -- npx -y my-mcp-package
```

### 方法 3: .mcp.json（チーム共有設定）

`.mcp.json.example` を参照。プロジェクトルートに `.mcp.json` として配置。

---

## スコープ（設定の適用範囲）

| スコープ | コマンドオプション | 設定場所 | 適用対象 |
|--------|-----------------|---------|--------|
| **local**（デフォルト） | なし | `~/.claude.json`（プロジェクト別） | 現在のプロジェクトのみ |
| **project** | `--scope project` | `.mcp.json`（プロジェクトルート） | チーム全員 |
| **user** | `--scope user` | `~/.claude.json`（全体） | 全プロジェクト |

```bash
# チーム共有設定として追加
claude mcp add --scope project --transport http github https://api.githubcopilot.com/mcp/

# 全プロジェクトで使える個人設定
claude mcp add --scope user --transport http notion https://mcp.notion.com/mcp
```

---

## MCPサーバーの管理

```bash
# 登録済みサーバー一覧
claude mcp list

# 特定サーバーの詳細
claude mcp get github

# サーバーの削除
claude mcp remove github

# インタラクティブ管理（Claude Code 内）
/mcp
```

---

## MCP プロンプト（スラッシュコマンドとして使う）

MCP サーバーが提供するプロンプトは自動的にスラッシュコマンドになります:

```
/mcp__<サーバー名>__<プロンプト名> [引数]
```

```bash
# GitHub MCP の場合
/mcp__github__list_prs
/mcp__github__pr_review 456

# カスタム MCP の場合
/mcp__myserver__analyze "data.csv"
```

---

## 人気の MCP サーバー

| サーバー | 用途 | 追加方法 |
|--------|------|--------|
| **GitHub** | PR・Issue・コードレビュー | HTTP: `https://api.githubcopilot.com/mcp/` |
| **Sentry** | エラー監視・ログ分析 | HTTP: `https://mcp.sentry.dev/mcp` |
| **PostgreSQL** | DB クエリ・スキーマ操作 | Stdio: `npx -y @bytebase/dbhub` |
| **Filesystem** | 高度なファイル操作 | Stdio: `npx -y @modelcontextprotocol/server-filesystem` |
| **Notion** | ドキュメント読み書き | HTTP: `https://mcp.notion.com/mcp` |
| **Slack** | メッセージ送受信 | HTTP: チームの Slack MCP エンドポイント |

---

## 環境変数の展開

`.mcp.json` 内で環境変数を参照できます:

```json
{
  "mcpServers": {
    "myapi": {
      "type": "http",
      "url": "${API_BASE_URL:-https://api.example.com}/mcp",
      "headers": {
        "Authorization": "Bearer ${API_KEY}"
      }
    }
  }
}
```

- `${VAR}` — 環境変数の値に展開
- `${VAR:-default}` — 変数が未設定の場合はデフォルト値を使用

---

## セットアップ手順

```bash
# 1. GitHub MCP を追加（要: GitHub Copilot）
claude mcp add --transport http github https://api.githubcopilot.com/mcp/

# 2. チーム共有設定を作成
cp claude-code-demos/04-mcp-tool-extension/.mcp.json.example .mcp.json
# .mcp.json を編集して認証情報を設定

# 3. 登録確認
claude mcp list

# 4. Claude Code で動作確認
# /mcp でサーバー一覧を確認
```

---

## カスタム MCP サーバーの作成

独自の MCP サーバーを Node.js で作成する最小サンプル:

```bash
# 詳細は demo.sh を参照
bash claude-code-demos/04-mcp-tool-extension/demo.sh --create-sample
```
