# 01 — スラッシュコマンド

Claude Code のインタラクティブモードで使える組み込みコマンド一覧と実践例。

---

## 組み込みコマンド一覧

### セッション管理

| コマンド | 説明 |
|---------|------|
| `/clear` | 会話をリセット（コンテキストを捨てて再出発） |
| `/compact` | コンテキストを手動で圧縮してトークン節約 |
| `/context` | 現在のトークン使用量・圧縮閾値を表示 |
| `/cost` | セッションのトークン消費量とAPI費用を表示 |
| `/session` | セッションID確認・過去セッション一覧 |

### 情報・ヘルプ

| コマンド | 説明 |
|---------|------|
| `/help` | コマンド一覧とショートカット表示 |
| `/doctor` | インストール・設定・フック等の診断 |
| `/debug` | デバッグモード切替 |

### 設定・カスタマイズ

| コマンド | 説明 |
|---------|------|
| `/config` | 設定をインタラクティブに編集 |
| `/keybindings` | `~/.claude/keybindings.json` をエディタで開く |
| `/memory` | CLAUDE.md（メモリファイル）を表示・編集 |
| `/permission` | 現在の権限ルールを一覧表示 |
| `/statusline` | ステータスラインの表示設定 |
| `/vim` | Vim モードのオン/オフ切替 |

### 拡張機能

| コマンド | 説明 |
|---------|------|
| `/hooks` | フックの表示・作成・編集・削除 |
| `/mcp` | MCP サーバーの管理 |
| `/agents` | サブエージェントの管理 |
| `/skills` | スキルの一覧と管理 |
| `/plugin` | プラグインの探索・管理 |

### タスク支援

| コマンド | 説明 |
|---------|------|
| `/commit` | git コミット作成（メッセージ省略可） |
| `/review-pr` | GitHub PR のコードレビュー |

---

## MCP プロンプトコマンド

MCP サーバーが提供するプロンプトは `/mcp__<サーバー名>__<プロンプト名>` で呼び出せます:

```
/mcp__github__list_prs
/mcp__github__pr_review 456
/mcp__jira__create_issue "バグ修正" high
```

---

## デモ手順

`demo.sh` を実行するか、以下を手動で試してください:

```bash
# 1. Claude Code を起動
claude

# 2. コスト確認
/cost

# 3. コンテキスト使用量確認
/context

# 4. 診断
/doctor

# 5. PR レビュー（GitHub CLI 必要）
/review-pr 1

# 6. コミット作成
/commit "feat: add initial project structure"

# 7. メモリ確認
/memory

# 8. 設定確認
/config

# 9. 権限確認
/permission
```

---

## よく使うワークフロー

### コスト意識しながら作業する

```
/context    <- トークン残量確認
（作業）
/cost       <- 消費額確認
/compact    <- 必要なら圧縮
```

### PR レビュー

```
/review-pr 123          <- PR番号で指定
/review-pr https://github.com/owner/repo/pull/123   <- URL でも可
```
