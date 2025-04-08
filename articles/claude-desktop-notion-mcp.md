---
title: "Claude DesktopとNotionをMCPで連携させてみた！"
emoji: "🔌"
type: "tech"
topics: ["Claude", "Notion", "MCP", "Nodejs", "API"]
published: true
---

## はじめに

こんにちは！この記事では、デスクトップ版Claude（Claude for Desktop）とNotionをModel Context Protocol（MCP）を使って連携させる方法をご紹介します。具体的には、Notion公式が提供している`makenotion/notion-mcp-server`というMCPサーバーを利用する手順について解説します。

MCPを活用することで、ClaudeはNotionのデータベースやページにアクセスし、新しいページの作成やコメントの追加など、様々な操作を直接実行できるようになります。これにより、ClaudeとNotionを組み合わせた高度なワークフローの自動化や効率化が可能になります。

## MCPとNotion MCPサーバーについて

### Model Context Protocol (MCP)とは？

Model Context Protocol（MCP）は、アプリケーションがLLM（大規模言語モデル）にコンテキストを提供するためのオープンな標準プロトコルです。簡単に言えば、「AIアプリのUSB-Cポート」のような役割を果たします。MCPを使うことで、異なるAIアプリケーションや外部ツールを簡単に連携させることができます。

### `makenotion/notion-mcp-server`について

`makenotion/notion-mcp-server`は、Notion公式が提供しているGitHubリポジトリで、Notion APIの機能をMCPサーバーとして公開してくれるパッケージです。このパッケージを利用することで、Claude DesktopのようなMCPクライアントからNotionのページやデータベースを操作できるようになります。

参考リンク:
- Model Context Protocol 公式サイト: [https://modelcontextprotocol.io/](https://modelcontextprotocol.io/)
- Notion Developers: [https://developers.notion.com/](https://developers.notion.com/)
- Notion MCP Server GitHub: [https://github.com/makenotion/notion-mcp-server](https://github.com/makenotion/notion-mcp-server)

## 前提条件

この記事の手順を実行するためには、以下のものが必要です：

- **Node.js: v18以上が必須** （重要: v18未満では動作しません！）
  - npm / npx: Node.jsに同梱されています
- デスクトップ版Claude（インストール済み）
- Notionアカウント
- **Notion Internal Integration Token: 事前に取得が必要**

特に重要な注意点として、Notion Integration Tokenを取得した後、**そのIntegrationをアクセスしたいNotionページやデータベースの「Connections」に追加する必要があります**。この手順を忘れると、APIが正しく動作せず、Claudeからデータにアクセスできなくなりますので、必ず行ってください。

## 設定手順

### 1. Notion Internal Integration Token の取得

1. Notionの [My Integrations](https://www.notion.so/my-integrations) ページへアクセスします
2. 「+ New integration」ボタンをクリックします
3. 以下の情報を入力します：
   - Name: 任意の名前（例: 「Claude Desktop Connection」）
   - Logo: 任意（デフォルトのままでOK）
   - Associated workspace: 連携したいワークスペースを選択
   - Capabilities: 必要な権限を選択（ページの読み書き、コメント追加など）

作成後、「Internal Integration Token」が表示されます。このトークンは**機密情報**ですので、安全に保管してください。このトークンは後ほどの設定で使用します。

> ⚠️ **重要**: 作成したIntegrationを、アクセスしたいNotionページやデータベースの「Connections」（⋯メニュー > Connections）に追加することを忘れないでください。この手順を行わないと、APIが権限エラーを返します。

### 2. Claude Desktop 設定ファイルの編集

Claude Desktopの設定ファイルを編集して、Notion MCPサーバーを追加します。設定ファイルの場所はOSによって異なります：

- macOS: `~/Library/Application Support/Claude/claude_desktop_config.json`
- Windows: `%APPDATA%\Claude\claude_desktop_config.json`

以下のJSON設定例を参考に、`mcpServers` オブジェクト内に `notionApi` サーバー定義を追加します。既存のサーバー定義（例: `filesystem`）がある場合は、その後にカンマ `,` を追加してから `notionApi` を記述してください。

```json:claude_desktop_config.json
{
  // 既存の globalShortcut などがあればそのまま残します
  "mcpServers": {
    // --- もし他のサーバーがあればここにあるはず ---
    "filesystem": {
      "command": "npx",
      "args": [
        "-y",
        "@modelcontextprotocol/server-filesystem",
        "C:\\Users\\<あなたのユーザー名>\\Desktop", // 例: Windows
        "/Users/<あなたのユーザー名>/Documents" // 例: macOS
      ]
    }, // <-- 他のサーバーがある場合、ここのカンマを忘れないでください

    // --- Notionサーバーの定義を追加 ---
    "notionApi": {
      "command": "npx",
      "args": ["-y", "github:makenotion/notion-mcp-server"],
      "env": {
        "OPENAPI_MCP_HEADERS": "{\"Authorization\": \"Bearer YOUR_NOTION_API_TOKEN\", \"Notion-Version\": \"2022-06-28\" }"
      }
    }
  }
}
```

**非常に重要**: 
- 上記のコードで `YOUR_NOTION_API_TOKEN` となっている部分を、ステップ1で取得した**実際のNotion APIトークン**に置き換えてください。このトークンが正しくないと、APIへの認証が失敗します。
- npmパッケージではなくGitHubリポジトリから直接インストールするため、`args`配列内の値が `"-y", "github:makenotion/notion-mcp-server"` となっていることに注意してください。

`env` 内の `OPENAPI_MCP_HEADERS` は、HTTPリクエストヘッダーに必要な認証情報（Authorizationヘッダー）とAPIバージョンを、環境変数としてnotion-mcp-serverプロセスに渡すための設定です。これによって、サーバーが適切な認証情報をつけてNotion APIにリクエストを送信できるようになります。

### 3. Node.jsのバージョン確認 (再掲)

**⚠️ 重要**: `makenotion/notion-mcp-server` およびその依存関係は**Node.js v18以上を必須**としています。古いバージョンではサーバーが起動しません。

以下のコマンドでNode.jsのバージョンを確認してください：

```bash
node -v
```

もしバージョンが古い場合（例: v16など）は、サーバーが起動時に `EBADENGINE` というエラーを出して失敗します。その場合は、Node.jsを公式サイトからv18以上にアップデートする必要があります。

### 4. Claude Desktopの再起動と確認

設定ファイルを正しく編集・保存した後、変更を反映させるためにデスクトップ版Claudeを**完全に終了**し、再度起動してください。

再起動後、チャット入力欄の右下に**ハンマー (🔨) アイコン**が表示されるかどうかを確認します。このアイコンをクリックすると利用可能なツールリストが表示されるので、そこに `notionApi` に関連するツール（例: `API-post-search`, `API-patch-page`, `API-post-database-query`など）が表示されていれば、設定が成功した証拠です。

## 使ってみる (実行例)

設定が成功したら、実際にClaudeにNotionに関するタスクを依頼してみましょう。以下に例を示します：

### 例1: Notionページにコメントを追加

```
「ミーティング議事録」という名前のNotionページに「今日の議論は活発でした」とコメントを追加してください
```

### 例2: 新しいページの作成

```
「プロジェクト管理」データベースの中に「新しい機能案」というタイトルのページを作成してください
```

### 例3: ページ内容の取得と要約

```
Notionのページ「aaaa1111-bbbb-2222-cccc-3333dddd4444」の内容を取得して要約してください
```

これらの指示に対して、ClaudeはMCPツール（notionApi）を呼び出す計画を立て、実行前にユーザーに承認を求めます。ユーザーが承認すると、Claudeは指定されたタスクを実行し、Notion上でコメントやページが作成されるといった結果が得られます。

## トラブルシューティング

設定がうまくいかない場合、以下の点を確認してください：

- **ハンマーアイコンが表示されない**:
  - JSON構文エラー（カンマの位置や閉じ括弧の不足等）がないか確認
  - Node.jsがインストールされているか確認
  - 設定ファイルのパスが正しいか確認

- **ツールは表示されるが実行に失敗する**:
  - Notion APIトークンが間違っているか無効になっていないか確認
  - IntegrationがアクセスしたいページやDBの「Connections」に追加されているか確認
  - Integrationに十分な権限（Capabilities）が付与されているか確認

- **Claude Desktopのログに `EBADENGINE` エラー**:
  - Node.jsのバージョンがv18未満である可能性。Node.jsをアップデートしてください。

- **Claude Desktopのログに `Request timed out` エラー**:
  - サーバープロセスが応答していない可能性。ネットワーク問題、トークン問題、サーバー内部エラーなどが考えられます。

Claude Desktopのログを確認するには、設定 > Developer > View Logs からログファイルを開くことができます。

## まとめ

この記事では、Notion公式が提供する`makenotion/notion-mcp-server`を使ってClaude DesktopとNotionをMCPで連携させる方法を解説しました。主な手順は、Notion API Tokenの取得、Claude Desktop設定ファイルの編集、そしてNode.jsバージョンの確認でした。

この連携により、Claudeのインターフェースから直接Notionを操作できるようになり、情報収集や文書作成のワークフローがより効率的になります。MCPは今後も様々なツールとの連携が拡大していくことが期待されており、AIアシスタントの活用範囲がさらに広がっていくでしょう。

## 参考情報

- Model Context Protocol: [https://modelcontextprotocol.io/](https://modelcontextprotocol.io/)
- Notion Developers: [https://developers.notion.com/](https://developers.notion.com/)
- Notion MCP Server GitHub: [https://github.com/makenotion/notion-mcp-server](https://github.com/makenotion/notion-mcp-server)
- Node.js: [https://nodejs.org/](https://nodejs.org/)
