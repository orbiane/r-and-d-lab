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
