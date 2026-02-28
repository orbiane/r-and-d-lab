# 02 — 設定・カスタマイズ

Claude Code の設定ファイル・CLAUDE.md・キーバインドのカスタマイズ方法。

---

## 設定ファイルの種類と優先順位

```
高
 ↑  managed settings      （IT管理者がデプロイ、ユーザー変更不可）
 ↑  コマンドライン引数    （--model, --allowedTools など）
 ↑  .claude/settings.local.json   （プロジェクト・ローカル専用）
 ↑  .claude/settings.json          （プロジェクト共有）
 ↑  ~/.claude/settings.json        （ユーザー全体）
低
```

---

## ファイル構成

```
~/.claude/                       # ユーザーレベル（全プロジェクトに適用）
├── settings.json
├── CLAUDE.md                    # ユーザーレベルのメモリ
└── keybindings.json

.claude/                         # プロジェクトレベル（gitで共有可）
├── settings.json
├── settings.local.json          # .gitignore 推奨（個人設定）
└── CLAUDE.md                    # プロジェクトのメモリ
```

---

## settings.json

`settings.json.example` を参照。主要フィールド:

### 権限ルール (`permissions`)

```json
{
  "permissions": {
    "allow": [
      "Bash(npm run *)",         // npm run で始まるコマンドを常に許可
      "Bash(git *)",             // git コマンドを許可
      "Read",                    // 全ファイル読み取りを許可
      "WebFetch(domain:github.com)"  // github.com へのフェッチを許可
    ],
    "deny": [
      "Bash(rm -rf *)",          // 危険な削除コマンドをブロック
      "Read(.env)"               // .env ファイル読み取りをブロック
    ],
    "ask": [
      "Bash(git push *)"         // git push は毎回確認
    ]
  }
}
```

**ワイルドカードの挙動:**
- `Bash(ls *)` — スペース後の `*` は単語境界マッチ（`ls -la` にマッチ、`lsof` にはマッチしない）
- `Bash(ls*)` — スペースなしの `*` はどこにでもマッチ

### デフォルトモード (`defaultMode`)

| モード | 動作 |
|--------|------|
| `default` | 初回ツール使用時に確認 |
| `acceptEdits` | ファイル編集を自動承認 |
| `plan` | 読み取り専用（編集・実行しない） |
| `bypassPermissions` | 全確認をスキップ（隔離環境専用） |

### モデル指定 (`model`)

```json
{ "model": "claude-sonnet-4-6" }
```

利用可能: `claude-opus-4-6`, `claude-sonnet-4-6`, `claude-haiku-4-5`

---

## CLAUDE.md

Claude が参照するプロジェクト情報・指示ファイル。Markdown 形式。

- **`~/.claude/CLAUDE.md`** — 全プロジェクトに適用するユーザー設定
- **`.claude/CLAUDE.md`** または **`CLAUDE.md`** — プロジェクト固有（git共有可）

`CLAUDE.md.example` を参照して自分のプロジェクト用に編集してください。

### 効果的な CLAUDE.md の書き方

1. **プロジェクト概要** — 目的と構成を簡潔に
2. **コード規約** — linter、フォーマッター、命名規則
3. **よく使うコマンド** — `npm test`, `make build` など
4. **禁止事項** — やってはいけないことを明示
5. **最近の決定事項** — レビューで判明した重要な知見

---

## keybindings.json

`keybindings.json.example` を参照。

```bash
# インタラクティブに編集
/keybindings

# または直接編集
code ~/.claude/keybindings.json
```

### コンテキスト一覧

| コンテキスト | 場面 |
|------------|------|
| `Global` | 常時 |
| `Chat` | プロンプト入力中 |
| `Autocomplete` | 補完候補表示中 |
| `Confirmation` | 権限確認ダイアログ |
| `Transcript` | 会話履歴表示中 |

### キー記法

```json
"ctrl+enter"        // Ctrl+Enter
"shift+tab"         // Shift+Tab
"meta+k"            // Cmd+K (Mac) / Win+K
"ctrl+k ctrl+s"     // コードシーケンス（2キー連続）
null                // バインド解除
```

---

## 環境変数

| 変数 | 説明 | 例 |
|------|------|---|
| `CLAUDE_CODE_ENABLE_TELEMETRY` | テレメトリ有効/無効 | `0` |
| `CLAUDE_AUTOCOMPACT_PCT_OVERRIDE` | 圧縮トリガー閾値(%) | `50` |
| `ENABLE_TOOL_SEARCH` | MCP ツール検索 | `auto` |
| `MAX_MCP_OUTPUT_TOKENS` | MCP 出力トークン上限 | `50000` |
| `MCP_TIMEOUT` | MCP 起動タイムアウト(ms) | `10000` |

```bash
# .env または shell 設定に追加
export CLAUDE_AUTOCOMPACT_PCT_OVERRIDE=60
export CLAUDE_CODE_ENABLE_TELEMETRY=0
```

---

## クイックセットアップ

```bash
# 1. ユーザー設定ディレクトリを確認
ls ~/.claude/

# 2. サンプルをコピーして編集
cp claude-code-demos/02-settings-customization/settings.json.example ~/.claude/settings.json
cp claude-code-demos/02-settings-customization/CLAUDE.md.example ~/.claude/CLAUDE.md

# 3. キーバインドを設定
cp claude-code-demos/02-settings-customization/keybindings.json.example ~/.claude/keybindings.json

# 4. 設定の診断
claude /doctor
```
