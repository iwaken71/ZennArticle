---
title: "GitHub MCPサーバーを使ってClaude DesktopからZenn記事を公開する方法"
emoji: "🚀"
type: "tech" # tech: 技術記事 / idea: アイデア
topics: ["Claude", "GitHub", "MCP", "Zenn", "AIアシスタント"]
published: false
---

## はじめに

AIアシスタントが進化を続ける中、Claude Desktopと外部ツールの連携が可能になり、ワークフローの自動化がますます現実的になってきました。

この記事では、GitHub公式が提供する**GitHub MCPサーバー**を使って、Claude DesktopからZenn記事を直接公開・管理する方法を解説します。Model Context Protocol (MCP)を活用することで、AIアシスタントがGitHubリポジトリを操作し、Zenn記事の作成、編集、公開までをシームレスに行えるようになります。

## Model Context Protocol (MCP)とは

Model Context Protocol (MCP)は、AIアシスタントと外部ツール・サービスを連携させるためのオープンな標準プロトコルです。簡単に言えば、AIモデルに外部の「目」と「手」を与えるインターフェースと考えることができます。

MCPを利用することで、Claude DesktopなどのAIアシスタントは以下のようなことが可能になります：

- ファイルシステムへのアクセス
- 外部APIの呼び出し
- データベースの操作
- GitHubリポジトリの管理
- その他様々なツール・サービスとの連携

## 前提条件

この記事の手順を実行するためには、以下のものが必要です：

1. **Claude Desktop**: インストール済みであること
2. **Docker**: GitHub MCPサーバーを実行するために必要
3. **GitHub アカウント**: Zennとの連携設定済み
4. **GitHub Personal Access Token**: リポジトリへのアクセス権を持つトークン
5. **Zenn用のGitHubリポジトリ**: 既に設定済みであること

## セットアップ手順

### 1. GitHub Personal Access Tokenの取得

まず、GitHub Personal Access Tokenを取得します：

1. GitHubにログインし、[Settings > Developer settings > Personal access tokens > Tokens (classic)](https://github.com/settings/tokens) に移動
2. 「Generate new token」をクリック
3. 以下の設定で新しいトークンを作成：
   - Note: Claude Desktop GitHub MCP（任意の名前）
   - Expiration: 必要に応じて設定（例: 90 days）
   - Select scopes: **repo** （リポジトリへの完全なアクセス権）
4. 「Generate token」をクリックしてトークンを生成
5. 表示されたトークンをコピーして安全な場所に保存（**このトークンは再表示されないので注意**）

### 2. Claude Desktop設定ファイルの編集

Claude Desktopの設定ファイルを編集して、GitHub MCPサーバーを追加します：

1. 設定ファイルの場所を開く：
   - Windows: `%APPDATA%\Claude\claude_desktop_config.json`
   - macOS: `~/Library/Application Support/Claude/claude_desktop_config.json`

2. `mcpServers` セクションに以下の設定を追加：

```json
{
  "mcpServers": {
    // 既存のサーバー設定があればそのまま残す
    
    "github": {
      "command": "docker",
      "args": [
        "run",
        "-i",
        "--rm",
        "-e",
        "GITHUB_PERSONAL_ACCESS_TOKEN",
        "ghcr.io/github/github-mcp-server"
      ],
      "env": {
        "GITHUB_PERSONAL_ACCESS_TOKEN": "YOUR_GITHUB_TOKEN"
      }
    }
  }
}
```

**重要**: `YOUR_GITHUB_TOKEN` の部分を、ステップ1で取得した実際のGitHub Personal Access Tokenに置き換えてください。

### 3. Docker の起動確認

GitHub MCPサーバーはDockerコンテナで実行されるため、Docker Desktopが起動していることを確認してください。

### 4. Claude Desktopの再起動

設定ファイルを保存したら、Claude Desktopを完全に終了し、再起動します。

### 5. 動作確認

Claude Desktopが起動したら、チャット入力欄の右下にハンマー（🔨）アイコンが表示されることを確認します。このアイコンをクリックすると、利用可能なツールリストが表示され、そこに GitHub 関連のツール（例: `create_repository`, `push_files`, `create_or_update_file` など）が表示されていれば設定成功です。

## Zenn記事の公開手順

GitHub MCPサーバーを設定したら、以下の手順でClaude DesktopからZenn記事を公開できます：

### 1. 記事コンテンツの作成

まずは、Claude Desktopに記事の内容を作成してもらいます：

```
「[記事のテーマ]」についての技術記事を書いてください。
Zennの記事として公開することを想定して、
マークダウン形式で書いてください。
```

Claudeが記事の内容を生成したら、次のステップに進みます。

### 2. 記事のリポジトリへの保存

Claudeに以下のように指示して、作成した記事をGitHubリポジトリに保存します：

```
この記事をGitHubの私のZennリポジトリに保存してください。
リポジトリは「[ユーザー名]/[リポジトリ名]」です。
ファイル名は「articles/[記事のスラッグ].md」にしてください。
published: falseで下書き状態にしてください。
```

Claudeは作成した記事内容をGitHub MCPサーバーを使ってリポジトリに保存します。これにより、Zennに下書き状態で記事が公開されます。

### 例：実際の操作手順

以下に、実際の操作例を示します：

1. **記事内容の作成依頼**：

```
「GitHub Actionsを使った自動デプロイ」についての技術記事を書いてください。
Zennの記事として公開することを想定して、マークダウン形式で書いてください。
```

2. **Claudeが記事を生成**

3. **記事のリポジトリへの保存依頼**：

```
この記事をGitHubの私のZennリポジトリに保存してください。
リポジトリは「myusername/zenn-content」です。
ファイル名は「articles/github-actions-autodeploy.md」にしてください。
published: falseで下書き状態にしてください。
```

4. **Claudeが記事の保存を実行**：

Claudeは以下のような手順でリポジトリに記事を保存します：
- GitHub MCPサーバーの `create_or_update_file` ツールを使用
- 正しいリポジトリパスとファイル名を指定
- Zennの形式に合わせたフロントマターを設定
- コミットメッセージを設定してプッシュ

これにより、Zennに下書き記事が反映されます。

## 記事の更新・編集

既存の記事を更新する場合も同様のプロセスで行えます：

1. **記事の読み込み**：

```
GitHubリポジトリ「myusername/zenn-content」の
「articles/github-actions-autodeploy.md」ファイルを読み込んでください。
```

2. **編集内容の指示**：

```
この記事の「デプロイ手順」セクションに、
環境変数の設定方法についての説明を追加してください。
```

3. **更新の保存**：

```
更新した内容をリポジトリに保存してください。
コミットメッセージは「環境変数の設定方法を追加」としてください。
```

## トラブルシューティング

設定や操作中に問題が発生した場合、以下の点を確認してください：

### ハンマーアイコンが表示されない

- JSON構文が正しいか確認（カンマ、括弧の不足など）
- Docker Desktopが起動しているか確認
- 設定ファイルのパスが正しいか確認

### GitHubのAPIリクエストが失敗する

- Personal Access Tokenが有効か確認
- トークンに十分な権限（repo）が付与されているか確認
- リポジトリ名が正確か、アクセス権があるか確認

### ファイルの作成・更新に失敗する

- ファイルパスが正しいか確認（例: `articles/` ディレクトリがあるか）
- コンテンツフォーマットが正しいか確認（Zennのフロントマターなど）
- ブランチの保護設定がないか確認

## まとめ

GitHub MCPサーバーを使うことで、Claude DesktopからZenn記事を直接公開・管理できるようになりました。この方法を活用すれば、記事作成から公開までのワークフローを効率化し、AIアシスタントの能力を最大限に活用できます。

今後、MCPエコシステムの発展に伴い、さらに多くのツールやサービスとの連携が可能になることでしょう。AIアシスタントとの協業により、コンテンツ作成の新たな可能性が広がっています。

## 参考リンク

- [GitHub MCP Server](https://github.com/github/github-mcp-server)
- [Model Context Protocol](https://modelcontextprotocol.io/)
- [Zenn GitHub連携の公式ガイド](https://zenn.dev/zenn/articles/connect-to-github)
- [Claude Desktop公式サイト](https://claude.ai/desktop)
