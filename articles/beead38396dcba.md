---
title: "Claude CodeのCLIオプションまとめ"
emoji: "🛠️"
type: "tech" # tech: 技術記事 / idea: アイデア
topics: ["AI", "CLI", "Claude", "AI活用"]
published: true
---

## Claude Code CLIオプション

こんにちは、イワケンです
Claude CodeのCLI（コマンドラインインターフェース）のオプション一覧を日本語でわかりやすくまとめました。

**引用元:** [公式ドキュメント（日本語版）](https://docs.anthropic.com/ja/docs/claude-code/cli-usage)

---

## 🎛️ 基本オプション一覧

| オプション/引数 | 説明 |
|-----------------|-------|
| `prompt` | 実行するプロンプト（必須） |
| `-d`, `--debug` | デバッグモードを有効にする |
| `--verbose` | verboseモードを有効化（設定より優先） |
| `-p`, `--print` | 標準出力に結果を表示して終了（パイプ処理向け） |
| `--output-format <format>` | 出力フォーマット（`text`/`json`/`stream-json`） |
| `--mcp-debug` | （非推奨）MCPデバッグモード有効化（`--debug`推奨） |
| `--dangerously-skip-permissions` | 権限チェックを無視（Docker内でのみ使用可） |
| `--allowedTools <tools...>` | 許可するツールのリストを指定 |
| `--disallowedTools <tools...>` | 禁止するツールのリストを指定 |
| `--mcp-config <file or string>` | MCPサーバーの設定（JSON形式）を読み込み |
| `-c`, `--continue` | 直近の会話を継続 |
| `-r`, `--resume [sessionId]` | 特定の会話を再開（IDまたは選択） |
| `--model <model>` | 使用するモデルを指定（例: `sonnet`、`opus`） |
| `-v`, `--version` | バージョン表示 |
| `-h`, `--help` | ヘルプ表示 |

---

## 🧭 サブコマンド

| サブコマンド | 説明 |
|--------------|-------|
| `config` | 設定管理（例: `claude config set -g theme dark`） |
| `mcp` | MCPサーバーの設定・管理 |
| `migrate-installer` | グローバルnpmインストールからローカルインストールへ移行 |
| `doctor` | Claude Codeのヘルスチェック |
| `update` | 最新バージョンへのアップデート |

---

## 💡 よくある使い方例

### doctor コマンド

Claude Codeのアップデート機能や設定のヘルスチェックを行います。

```bash
claude doctor
```

### update コマンド

Claude Codeのバージョンを最新にアップデートします。
```bash
claude update
```

### 標準出力で結果を得たい場合

```bash
claude "日本語でブログ記事のタイトル案を5つ出して"
```

### JSONで出力したい場合

```bash
claude "10個のプロンプトアイデアを出して" --print --output-format json
```

---

## 🔗 参考リンク

- [Claude Code公式ドキュメント（日本語版）](https://docs.anthropic.com/ja/docs/claude-code)
- [CLIの使用方法詳細](https://docs.anthropic.com/ja/docs/claude-code/cli-usage)

