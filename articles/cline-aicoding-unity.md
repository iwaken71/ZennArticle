---
title: "Unityエンジニア向け、AIプログラミング Clineの始め方"
emoji: "🤖"
type: "tech"
topics: ["Unity", "Cline", "AI", "VSCode", "OpenRouter"]
published: false
publication_name: "iwakenlab_book"
---

# はじめに

こんにちは、XR好きエンジニアのイワケンです。
最近、AIを活用したプログラミングが注目を集めていますが、「Unityは使えるけどAIプログラミングは分からない...」という方も多いのではないでしょうか？

この記事では、UnityエンジニアがAIプログラミングを始めるための第一歩として、VSCode拡張機能の「Cline」の設定方法を詳しく解説します。

## AIプログラミングとは？

AIプログラミングとは、AIアシスタントと対話しながらコードを書いていく新しいプログラミング手法です。以下のようなメリットがあります：

- コードの自動生成
- エラーの解決支援
- リファクタリングの提案
- APIの使い方のアドバイス

特にUnityの開発では、コンポーネントの実装やバグの修正が効率的に行えます。

# 前提条件

- VSCodeがインストールされていること
- Unityプロジェクトが既に存在していること

# 1. Clineのセットアップ

## VSCode拡張機能のインストール

Clineは、VSCode上でAIアシスタントと対話するための拡張機能です。この拡張機能をインストールする理由は、以下の通りです：

- **コード補完の強化**: 従来のIntelliSenseよりも文脈を理解した補完が可能
- **自然言語での対話**: プログラミング言語だけでなく、日本語での指示が可能
- **Unity特化の支援**: Unityの特殊なAPI構造を理解したサポートが受けられる

インストール手順：

1. VSCodeを開く
2. 拡張機能タブ（Ctrl+Shift+X）を開く
3. 検索バーで「Cline」を検索
4. 「Cline - Your AI Programming Assistant」をインストール

![Clineのインストール画面](/images/cline/install.png)
*VSCodeの拡張機能マーケットプレイスでClineを検索した画面*

## 基本設定

### ワークスペースの設定

Unityプロジェクトで効果的にClineを使用するためには、適切な設定が必要です。これらの設定が重要な理由は：

- **プロジェクトパスの設定**: AIがプロジェクト全体の構造を理解し、適切な提案をするために必要
- **インラインサジェストの有効化**: コーディング中にリアルタイムで提案を受け取るために必要
- **アセンブリ参照**: UnityのAPIをAIが理解するために必要な情報を提供

設定手順：

1. VSCodeでUnityプロジェクトのフォルダを開く
2. `.vscode`フォルダ内の`settings.json`を開く（ない場合は作成）
3. 以下の設定を追加：

```json
{
  "cline.project.path": "プロジェクトのパス",
  "editor.inlineSuggest.enabled": true
}
```

![VSCodeの設定画面](/images/cline/settings.png)
*VSCodeの設定画面でCline関連の設定を行っている様子*

# 2. OpenRouterの設定

## OpenRouterとは？

OpenRouterは、様々なAIモデルを統一的なインターフェースで利用できるサービスです。OpenRouterを使用する理由は以下の通りです：

- **多様なAIモデルへのアクセス**: Claude、GPT-4など複数の高性能AIモデルを一つのAPIで利用可能
- **コスト効率**: 使用量に応じた課金体系で、開発初期段階でのコスト削減が可能
- **高度なコード生成能力**: 無料のAIモデルよりも高品質なコード生成が可能
- **Unity固有の知識**: 特にClaude 3.5などの高性能モデルはUnityの知識が豊富

![OpenRouterの概要](/images/cline/openrouter_overview.png)
*OpenRouterが提供する様々なAIモデルとその特徴*

## アカウント作成手順

OpenRouterのアカウントを作成する必要がある理由：

- **APIキーの取得**: Clineと連携するために必要
- **使用量の管理**: 利用状況の確認とコスト管理
- **モデル選択の自由**: 様々なAIモデルから最適なものを選択可能

手順：

1. [OpenRouter公式サイト](https://openrouter.ai/)にアクセス
2. 右上の「Sign Up」をクリック
3. GitHubアカウントでログイン
4. 「Create Account」をクリック

![OpenRouterのサインアップ画面](/images/cline/openrouter_signup.png)
*OpenRouterのアカウント作成画面*

## APIキーの取得

APIキーが必要な理由：

- **認証**: OpenRouterのサービスを利用するための認証情報
- **使用量の追跡**: 個人の使用量を正確に計測するため
- **セキュリティ**: 不正利用を防止するため

手順：

1. ダッシュボードの「API Keys」タブを開く
2. 「Create New Key」をクリック
3. 表示されたAPIキーをコピー（このキーは一度しか表示されないので注意）

![OpenRouterのAPIキー取得画面](/images/cline/openrouter_apikey.png)
*OpenRouterのAPIキー作成画面*

## Clineでの設定

ClineにOpenRouterのAPIキーを設定する理由：

- **高性能モデルの利用**: 無料版よりも高度なコード生成能力を活用
- **カスタマイズ**: 自分の好みや用途に合わせたモデル選択が可能
- **応答速度の向上**: 適切なモデル選択による処理速度の最適化

手順：

1. VSCodeのコマンドパレット（Ctrl+Shift+P）を開く
2. 「Cline: Open Settings」を選択
3. 「API Key」の欄にOpenRouterのAPIキーを貼り付け
4. 「Save」をクリック

![ClineのAPIキー設定画面](/images/cline/cline_apikey.png)
*ClineにOpenRouterのAPIキーを設定している画面*

# 3. Claude 3.5への切り替え

## Claude 3.5の特徴

Claude 3.5を選択する理由：

- **Unity特化の知識**: Unity APIに関する深い理解を持っている
- **日本語対応**: 日本語での指示に対する理解度が高い
- **コンテキスト理解**: 長いコード全体の文脈を理解できる
- **エラー解析能力**: 複雑なエラーの原因を特定し、解決策を提案できる

主な特徴：

- より高度なコード理解
- 正確なコード生成
- 詳細なエラー解析
- 日本語での対話が可能

![Claude 3.5の特徴](/images/cline/claude_features.png)
*Claude 3.5の主な特徴と他のモデルとの比較*

## 切り替え手順

Claude 3.5に切り替える理由：

- **最新の機能**: 最新のモデルによる最高品質の応答
- **Unity固有の問題解決**: Unity開発特有の問題に対する理解度の向上
- **日本語サポート**: 日本語での指示に対する応答品質の向上

手順：

1. VSCodeのコマンドパレット（Ctrl+Shift+P）を開く
2. 「Cline: Open Settings」を選択
3. 「Model」の欄で「anthropic/claude-3-opus-20240229」を選択
4. 「Save」をクリック

![Claudeモデル選択画面](/images/cline/claude_selection.png)
*ClineでClaude 3.5を選択している画面*

## 推奨設定

これらの設定が重要な理由：

- **temperature**: 創造性と正確性のバランスを調整（低いと正確、高いと創造的）
- **maxTokens**: 長いコードや詳細な説明を生成するために必要
- **assembly.references**: UnityのAPIをAIが理解するために必要な参照情報

```json
{
  "cline.model.temperature": 0.7,  // 創造性と正確性のバランスを取る値
  "cline.model.maxTokens": 4000,   // 長いコードや詳細な説明に必要
  "cline.assembly.references": [    // Unityの型情報を提供
    "Library/ScriptAssemblies/UnityEngine.dll",
    "Library/ScriptAssemblies/UnityEngine.CoreModule.dll",
    "Library/ScriptAssemblies/UnityEngine.PhysicsModule.dll"
  ]
}
```

![推奨設定の効果](/images/cline/settings_effect.png)
*異なる設定値による生成コードの品質比較*

# 4. Unity開発での具体的な使用例

## スクリプト作成の基本

Clineを使ったスクリプト作成が効率的な理由：

- **時間短縮**: 基本的なコンポーネント構造を素早く生成
- **ベストプラクティス**: 最新のUnityの推奨パターンに沿ったコード生成
- **学習効果**: AIが生成するコードから学ぶことができる

手順：

1. Unityプロジェクト内で新しいスクリプトファイルを作成
2. Clineに日本語で指示を出す。例：
   ```
   「プレイヤーの移動とジャンプができるコンポーネントを作成して」
   ```
3. 生成されたコードを確認し、必要に応じて修正を依頼

![Clineによるコード生成例](/images/cline/code_generation.png)
*Clineに指示を出してPlayerControllerを生成している様子*

## AIとの対話例

対話形式の開発が効果的な理由：

- **イテレーティブな開発**: 段階的に機能を追加・改善できる
- **自然な指示**: プログラミング言語ではなく自然言語で指示できる
- **学習曲線の緩和**: 複雑なAPIの詳細を覚えなくても実装できる

対話例：

```
ユーザー：「このPlayerControllerにダッシュ機能を追加したいです」

Cline：「以下のようにダッシュ機能を実装できます：」

[コード生成例...]

ユーザー：「ダッシュのクールダウンも付けたいです」

Cline：「承知しました。以下のように修正します：」

[改善されたコード...]
```

![Clineとの対話例](/images/cline/conversation.png)
*Clineとの対話を通じて機能を追加していく様子*

## よくある質問とトラブルシューティング

1. **生成されたコードが動かない場合**
   - エラーメッセージをClineに共有
   - 具体的な状況を説明
   - 必要な参照が設定されているか確認

2. **日本語が通じない場合**
   - 設定で言語を確認
   - モデルが正しく選択されているか確認
   - より具体的な表現を使用

3. **補完が遅い場合**
   - インターネット接続を確認
   - VSCodeの再起動
   - キャッシュのクリア

# おわりに

AIプログラミングは、決して難しいものではありません。Unityの知識があれば、Clineを使って徐々にAIプログラミングに慣れていくことができます。

## Tips

1. 最初は小さな機能から試してみる
2. エラーメッセージは具体的に共有する
3. 日本語での対話を活用する
4. Unity固有の用語（Transform、Rigidbodyなど）を使用する
5. 生成されたコードは必ず理解してから使用する

AIプログラミングは、私たちUnityエンジニアの強力な味方になります。ぜひClineを活用して、効率的な開発を実現してください！
