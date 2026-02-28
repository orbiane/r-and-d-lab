#!/usr/bin/env bash
# =============================================================================
# Claude Code MCP ツール拡張 デモ
# =============================================================================
# MCPサーバーの追加・管理・カスタムサーバー作成を示すデモスクリプト。
# =============================================================================

set -euo pipefail

BOLD='\033[1m'
CYAN='\033[0;36m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RESET='\033[0m'

header() { echo -e "\n${BOLD}${CYAN}== $* ==${RESET}"; }
info()   { echo -e "${GREEN}▶${RESET} $*"; }
note()   { echo -e "${YELLOW}NOTE:${RESET} $*"; }
cmd()    { echo -e "  ${BOLD}\$${RESET} $*"; }
sub()    { echo -e "  ${BLUE}→${RESET} $*"; }

# ──────────────────────────────────────────────────────────────────────────────
# --create-sample オプション: カスタム MCP サーバーのサンプルを生成
# ──────────────────────────────────────────────────────────────────────────────
if [[ "${1:-}" == "--create-sample" ]]; then
  SAMPLE_DIR="./mcp-sample-server"
  mkdir -p "$SAMPLE_DIR"

  cat > "$SAMPLE_DIR/server.js" << 'JSEOF'
#!/usr/bin/env node
// =============================================================================
// カスタム MCP サーバー — 最小サンプル（Node.js）
// =============================================================================
// このサーバーは stdin/stdout (stdio transport) で Claude Code と通信します。
// "hello" ツールを1つ提供するシンプルな例です。
// =============================================================================

const readline = require("readline");

const rl = readline.createInterface({ input: process.stdin });

// MCP JSON-RPC プロトコルの実装
function send(obj) {
  process.stdout.write(JSON.stringify(obj) + "\n");
}

rl.on("line", (line) => {
  let req;
  try {
    req = JSON.parse(line);
  } catch {
    return;
  }

  const { id, method, params } = req;

  switch (method) {
    // サーバー情報
    case "initialize":
      send({
        jsonrpc: "2.0",
        id,
        result: {
          protocolVersion: "2024-11-05",
          serverInfo: { name: "sample-mcp-server", version: "1.0.0" },
          capabilities: { tools: {}, prompts: {} },
        },
      });
      break;

    // ツール一覧
    case "tools/list":
      send({
        jsonrpc: "2.0",
        id,
        result: {
          tools: [
            {
              name: "hello",
              description: "指定した名前に挨拶を返すシンプルなツール",
              inputSchema: {
                type: "object",
                properties: {
                  name: { type: "string", description: "挨拶する相手の名前" },
                },
                required: ["name"],
              },
            },
            {
              name: "timestamp",
              description: "現在の日時を返す",
              inputSchema: { type: "object", properties: {} },
            },
          ],
        },
      });
      break;

    // ツール実行
    case "tools/call":
      if (params.name === "hello") {
        const name = params.arguments?.name || "World";
        send({
          jsonrpc: "2.0",
          id,
          result: {
            content: [{ type: "text", text: `こんにちは、${name}！` }],
          },
        });
      } else if (params.name === "timestamp") {
        send({
          jsonrpc: "2.0",
          id,
          result: {
            content: [
              {
                type: "text",
                text: new Date().toLocaleString("ja-JP", {
                  timeZone: "Asia/Tokyo",
                }),
              },
            ],
          },
        });
      } else {
        send({
          jsonrpc: "2.0",
          id,
          error: { code: -32601, message: `Unknown tool: ${params.name}` },
        });
      }
      break;

    // プロンプト一覧（スラッシュコマンドになる）
    case "prompts/list":
      send({
        jsonrpc: "2.0",
        id,
        result: {
          prompts: [
            {
              name: "greet",
              description: "挨拶プロンプト（/mcp__sample-mcp-server__greet として使える）",
              arguments: [
                { name: "name", description: "名前", required: false },
              ],
            },
          ],
        },
      });
      break;

    case "prompts/get":
      send({
        jsonrpc: "2.0",
        id,
        result: {
          description: "挨拶を行うプロンプト",
          messages: [
            {
              role: "user",
              content: {
                type: "text",
                text: `${params.arguments?.name || "ユーザー"} に丁寧に挨拶してください。`,
              },
            },
          ],
        },
      });
      break;

    default:
      send({
        jsonrpc: "2.0",
        id: id ?? null,
        result: null,
      });
  }
});
JSEOF

  cat > "$SAMPLE_DIR/package.json" << 'PKGEOF'
{
  "name": "sample-mcp-server",
  "version": "1.0.0",
  "description": "Claude Code カスタム MCP サーバー サンプル",
  "main": "server.js",
  "bin": {
    "sample-mcp-server": "./server.js"
  },
  "scripts": {
    "start": "node server.js"
  }
}
PKGEOF

  chmod +x "$SAMPLE_DIR/server.js"

  echo ""
  echo -e "${GREEN}サンプル MCP サーバーを生成しました: $SAMPLE_DIR/${RESET}"
  echo ""
  echo "Claude Code に登録:"
  echo "  claude mcp add --transport stdio sample-mcp-server -- node $PWD/$SAMPLE_DIR/server.js"
  echo ""
  echo "動作確認:"
  echo "  claude mcp get sample-mcp-server"
  echo ""
  echo "Claude Code 内で使用:"
  echo "  hello ツールを使って「田中さん」に挨拶して"
  echo "  /mcp__sample-mcp-server__greet 田中"
  echo ""
  exit 0
fi

# ──────────────────────────────────────────────────────────────────────────────
# メインデモ
# ──────────────────────────────────────────────────────────────────────────────
header "Claude Code MCP ツール拡張 デモ"
echo ""
echo "このデモでは MCP サーバーの追加・管理方法を紹介します。"

# ------------------------------------------------------------------------------
header "1. MCP サーバーの追加"
# ------------------------------------------------------------------------------
info "HTTP サーバー（クラウドサービス）の追加"
cmd "claude mcp add --transport http github https://api.githubcopilot.com/mcp/"
cmd "claude mcp add --transport http sentry https://mcp.sentry.dev/mcp"
echo ""

info "Stdio サーバー（ローカルプロセス）の追加"
cmd "claude mcp add --transport stdio \\"
sub "  --env POSTGRESQL_URL=postgres://user:pass@localhost/db \\"
sub "  postgres \\"
sub "  -- npx -y @bytebase/dbhub"
echo ""

info "チーム共有設定として追加（.mcp.json に書き込まれる）"
cmd "claude mcp add --scope project --transport http github https://api.githubcopilot.com/mcp/"
echo ""

# ------------------------------------------------------------------------------
header "2. MCP サーバーの管理"
# ------------------------------------------------------------------------------
info "登録済みサーバー一覧"
cmd "claude mcp list"
echo ""

info "特定サーバーの詳細"
cmd "claude mcp get github"
echo ""

info "サーバーの削除"
cmd "claude mcp remove github"
echo ""

info "インタラクティブ管理（Claude Code 内）"
cmd "/mcp"
echo ""

# ------------------------------------------------------------------------------
header "3. MCP プロンプト（スラッシュコマンド）"
# ------------------------------------------------------------------------------
info "MCP サーバーのプロンプトはスラッシュコマンドとして使える"
sub "書式: /mcp__<サーバー名>__<プロンプト名> [引数]"
echo ""
cmd "/mcp__github__list_prs"
cmd "/mcp__github__pr_review 456"
cmd "/mcp__myserver__analyze \"data.csv\""
echo ""

# ------------------------------------------------------------------------------
header "4. .mcp.json（チーム共有設定ファイル）"
# ------------------------------------------------------------------------------
info "プロジェクトルートに .mcp.json を置くとチーム全員に適用"
cmd "cp claude-code-demos/04-mcp-tool-extension/.mcp.json.example .mcp.json"
cmd "# .mcp.json を編集して環境変数名を確認"
cmd "claude mcp list  # .mcp.json のサーバーが表示される"
echo ""
note ".mcp.json は git で共有可。APIキーは環境変数で渡すこと"

# ------------------------------------------------------------------------------
header "5. カスタム MCP サーバーの作成"
# ------------------------------------------------------------------------------
info "Node.js で独自 MCP サーバーを作成"
cmd "bash claude-code-demos/04-mcp-tool-extension/demo.sh --create-sample"
sub "→ mcp-sample-server/ が生成されます"
echo ""
cmd "claude mcp add --transport stdio sample \\"
sub "  -- node mcp-sample-server/server.js"
echo ""

# ------------------------------------------------------------------------------
header "まとめ"
# ------------------------------------------------------------------------------
echo ""
echo "  MCP を使うと Claude Code に以下が追加できます:"
echo "  - 外部サービスのツール（GitHub、DB、Slack など）"
echo "  - カスタムスラッシュコマンド"
echo "  - 社内 API との連携"
echo ""
echo "  詳細: claude-code-demos/04-mcp-tool-extension/README.md"
echo ""
