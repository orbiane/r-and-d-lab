# 03 — フック・自動化

Claude Code のフックシステムを使って、ツール実行の前後に任意の処理を差し込む方法。

---

## フックとは

フックは、Claude Code のライフサイクルの特定のタイミングで**自動実行される**シェルコマンドです。
LLM の判断ではなく**決定論的**に動作します。

主な用途:
- 危険なコマンドの事前ブロック
- コード変更後の自動フォーマット
- デスクトップ通知の送信
- ログ・監査記録
- 環境情報のセッション注入

---

## フックイベント一覧

| イベント | 発火タイミング | マッチャー |
|---------|--------------|----------|
| `SessionStart` | セッション開始・再開時 | `startup`, `resume`, `clear`, `compact` |
| `UserPromptSubmit` | プロンプト送信直後（Claude処理前） | — |
| `PreToolUse` | ツール実行前（ブロック可能） | ツール名 regex |
| `PermissionRequest` | 権限確認ダイアログ表示時 | ツール名 regex |
| `PostToolUse` | ツール実行後（成功時） | ツール名 regex |
| `PostToolUseFailure` | ツール実行後（失敗時） | ツール名 regex |
| `Notification` | Claude が入力待ちになったとき | `permission_prompt`, `idle_prompt` |
| `Stop` | Claude の応答が完了したとき | — |
| `PreCompact` | コンテキスト圧縮前 | `manual`, `auto` |
| `SessionEnd` | セッション終了時 | `clear`, `logout`, `other` |

---

## フックの入出力

### stdin（全フックが受け取る JSON）

```json
{
  "session_id": "abc123",
  "cwd": "/home/user/project",
  "hook_event_name": "PreToolUse",
  "tool_name": "Bash",
  "tool_input": {
    "command": "npm test"
  }
}
```

### 終了コードの意味

| 終了コード | 意味 |
|---------|------|
| `0` | 処理を続行（許可） |
| `2` | 処理をブロック（拒否） |
| その他 | 続行するが stderr を Claude に渡す |

### JSON 出力でブロック理由を返す

```bash
echo '{"decision": "deny", "reason": "rm -rf は禁止されています"}'
exit 2
```

---

## フックの種類

### 1. command（シェルスクリプト）

```json
{
  "type": "command",
  "command": ".claude/hooks/my-hook.sh"
}
```

### 2. prompt（LLM による判断）

```json
{
  "type": "prompt",
  "model": "haiku",
  "prompt": "このコマンドは安全ですか？安全なら {\"ok\": true} を返してください。"
}
```

### 3. agent（ツール使用可能なサブエージェント）

```json
{
  "type": "agent",
  "prompt": "テストが全て通過しているか確認してください。",
  "timeout": 120
}
```

---

## 設定方法

`settings.json` の `hooks` セクションに記述します。
このデモの `settings.json` を参照してください。

```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Bash",
        "hooks": [
          {
            "type": "command",
            "command": ".claude/hooks/validate-command.sh"
          }
        ]
      }
    ],
    "PostToolUse": [
      {
        "matcher": "Edit|Write",
        "hooks": [
          {
            "type": "command",
            "command": ".claude/hooks/auto-format.sh"
          }
        ]
      }
    ]
  }
}
```

---

## この デモに含まれるフック

| スクリプト | 説明 |
|---------|------|
| `hooks/protect-files.sh` | 機密ファイルへの書き込みをブロック |
| `hooks/validate-command.sh` | 危険な Bash コマンドをブロック |
| `hooks/auto-format.sh` | ファイル変更後に Prettier を自動実行 |
| `hooks/notify.sh` | Claude が入力待ちになったら通知 |
| `hooks/session-context.sh` | セッション開始時にコンテキストを注入 |

---

## セットアップ手順

```bash
# 1. フックスクリプトに実行権限を付与
chmod +x claude-code-demos/03-hooks-automation/hooks/*.sh

# 2. プロジェクトの .claude/ ディレクトリにコピー
mkdir -p .claude/hooks
cp claude-code-demos/03-hooks-automation/hooks/*.sh .claude/hooks/

# 3. settings.json をコピー
cp claude-code-demos/03-hooks-automation/settings.json .claude/settings.json

# 4. 動作確認
claude /hooks
```

---

## デバッグ方法

```bash
# フックの入力を手動でテスト
echo '{"tool_name":"Bash","tool_input":{"command":"rm -rf /"}}' \
  | bash .claude/hooks/validate-command.sh
echo "終了コード: $?"

# Claude Code のデバッグモード
claude --debug hooks
```
