---
title: "Notion MCPをwindsurfから実行する"
emoji: "🌊"
type: "tech" # tech: 技術記事 / idea: アイデア
topics: ["Notion", "MCP", "windsurf", "API", "自動化"]
published: true # 公開設定に変更
---

## はじめに

MCPとは「Model-Calling-Protocol」の略で、AIモデルを呼び出すための統一された規格です。特に複数のAIモデルを連携させる場合や、さまざまなツールから一貫した方法でAIモデルを利用したい場合に便利です。

[windsurf](https://github.com/AndrewWalsh/windsurf)はNode.jsベースのオープンソースプロジェクトで、MCPクライアントとして機能し、さまざまなAIモデルプロバイダーとの連携を簡単に実現できるツールです。

この記事では、NotionのAPIとMCPを組み合わせて、windsurfから実行する方法を解説します。これにより、AIの力を借りてNotionデータベースの自動更新や情報抽出などが可能になります。

## 前提条件と環境構築

### 必要なもの

- Node.js（v16以上）
- npm または yarn
- Notionアカウント
- Notion APIキー（後述）
- 基本的なJavaScript/TypeScriptの知識

### 環境構築

まずはwindsurfをインストールします。ターミナルで以下のコマンドを実行しましょう。

```bash
# npmの場合
npm install -g windsurf

# yarnの場合
yarn global add windsurf
```

インストールが完了したら、バージョンを確認してみましょう。

```bash
windsurf --version
```

正しくインストールされていれば、バージョン番号が表示されます。

## Notion MCPの設定

### Notion APIキーの取得

1. [Notion Developers](https://www.notion.so/my-integrations) にアクセスして、ログインします。
2. 「+ New integration」ボタンをクリックします。
3. インテグレーションの名前（例: My Windsurf Integration）を入力し、ワークスペースを選択します。
4. 必要な権限（Read, Update, Insert）を選択します。
5. 「Submit」をクリックして統合を作成します。
6. 表示されたシークレットキーをコピーします。これが「Notion API Secret」です。

> **重要**: この秘密鍵は公開しないように注意しましょう。.envファイルなどで安全に管理してください。

### Notion統合をページに接続する

1. Notionで連携したいページやデータベースを開きます。
2. ページの右上にある「...」（三点リーダー）をクリックします。
3. 「Add connections」を選択します。
4. 先ほど作成した統合を選択して「Confirm」をクリックします。

これで、このページやデータベースにAPIからアクセスできるようになりました。

## windsurfプロジェクトの設定

プロジェクトディレクトリを作成し、初期化します。

```bash
mkdir notion-mcp-project
cd notion-mcp-project
npm init -y
```

必要なパッケージをインストールします。

```bash
npm install @notionhq/client dotenv
```

`.env`ファイルを作成して、Notion APIキーを設定します。

```
NOTION_API_KEY=your_notion_api_key_here
NOTION_DATABASE_ID=your_database_id_here
```

> **注意**: `.gitignore`ファイルに`.env`を追加して、秘密鍵が公開リポジトリにコミットされないようにしましょう。

## windsurfからNotion MCPを実行するコード

まず、基本的なNotionクライアントを設定するファイルを作成します。`notion-client.js`というファイル名で保存してください。

```javascript
// notion-client.js
require('dotenv').config();
const { Client } = require('@notionhq/client');

// Notion APIクライアントの初期化
const notion = new Client({
  auth: process.env.NOTION_API_KEY,
});

const databaseId = process.env.NOTION_DATABASE_ID;

// データベースからデータを取得する関数
async function getDatabase() {
  try {
    const response = await notion.databases.query({
      database_id: databaseId,
    });
    return response.results;
  } catch (error) {
    console.error("Error fetching database:", error);
    return null;
  }
}

// 新しいページを作成する関数
async function addItem(title, description) {
  try {
    const response = await notion.pages.create({
      parent: {
        database_id: databaseId,
      },
      properties: {
        Name: {
          title: [
            {
              text: {
                content: title,
              },
            },
          ],
        },
        Description: {
          rich_text: [
            {
              text: {
                content: description,
              },
            },
          ],
        },
      },
    });
    return response;
  } catch (error) {
    console.error("Error adding item:", error);
    return null;
  }
}

module.exports = {
  getDatabase,
  addItem,
};
```

次に、windsurfからNotionクライアントを呼び出すためのMCP連携コードを作成します。`windsurf-notion-mcp.js`というファイル名で保存します。

```javascript
// windsurf-notion-mcp.js
const { getDatabase, addItem } = require('./notion-client');

// MCP準拠のハンドラー関数
async function handleNotionMCP(request) {
  const { action, params } = request;
  
  switch (action) {
    case 'getDatabase':
      return await getDatabase();
    
    case 'addItem':
      const { title, description } = params;
      return await addItem(title, description);
    
    default:
      return {
        error: "Unknown action",
        message: `Action '${action}' is not supported.`
      };
  }
}

// windsurfエントリーポイント
async function main() {
  // コマンドライン引数からリクエストを取得
  const requestArg = process.argv[2];
  
  if (!requestArg) {
    console.error("No request provided. Usage: node windsurf-notion-mcp.js '{\"action\": \"getDatabase\"}'");
    process.exit(1);
  }
  
  try {
    const request = JSON.parse(requestArg);
    const result = await handleNotionMCP(request);
    console.log(JSON.stringify(result, null, 2));
  } catch (error) {
    console.error("Error processing request:", error);
    process.exit(1);
  }
}

main();
```

## windsurf設定ファイルの作成

windsurfがこのMCP実装を利用できるように設定ファイルを作成します。`windsurf.config.js`という名前で保存します。

```javascript
// windsurf.config.js
module.exports = {
  providers: {
    notion: {
      type: 'custom',
      command: 'node windsurf-notion-mcp.js',
      timeout: 30000, // 30 seconds
    },
  },
};
```

## 実行と動作確認

### データベース情報の取得

windsurfを使用してNotionデータベースの情報を取得してみましょう。

```bash
windsurf run notion '{"action": "getDatabase"}'
```

### 新しいアイテムの追加

Notionデータベースに新しいアイテムを追加します。

```bash
windsurf run notion '{"action": "addItem", "params": {"title": "テストタイトル", "description": "これはwindsurfとMCPを使って追加されたテストアイテムです。"}}'
```

### 実行結果の確認

コマンド実行後、JSON形式のレスポンスが表示されます。また、Notionのデータベースを開いて、新しいアイテムが追加されていることを確認しましょう。

## トラブルシューティング

### よくあるエラー

1. **認証エラー**: Notion APIキーが正しく設定されているか確認してください。
   ```
   Error: APIキーが無効です
   ```

2. **アクセス権限エラー**: NotionページにAPIインテグレーションが接続されているか確認してください。
   ```
   Error: この統合はこのリソースにアクセスする権限がありません
   ```

3. **JSONパースエラー**: コマンドライン引数のJSON形式が正しいか確認してください。
   ```
   Error: Unexpected token in JSON
   ```

## まとめ

この記事では、NotionのAPIをMCPの形式でwindsurfから実行する方法を解説しました。これにより：

- MCPという統一されたプロトコルでNotionと対話できるようになりました
- windsurfを使って、他のAIツールとNotionを連携させる基盤ができました
- シンプルなコードで、Notionデータベースの取得と更新ができるようになりました

今回は基本的な機能だけを実装しましたが、これを拡張することで、AIを使ったNotionデータの分析や、定期的なデータ更新、他のサービスとの連携など、さまざまな可能性が広がります。

## 発展的な使い方

- OpenAIやClaudeなどのAIモデルと組み合わせて、Notionデータの自動要約や分類を行う
- GitHubやSlackなど他のサービスと連携して、タスク管理を自動化する
- カスタムMCPプロバイダーを作成して、独自の機能を追加する

## 参考情報

- [Notion API公式ドキュメント](https://developers.notion.com/)
- [windsurf GitHub リポジトリ](https://github.com/AndrewWalsh/windsurf)
- [Notion JavaScript SDK](https://github.com/makenotion/notion-sdk-js)
- [MCP (Model Calling Protocol)の仕様](https://github.com/AndrewWalsh/model-calling-protocol)
