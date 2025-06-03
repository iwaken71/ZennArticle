---
title: "Claude Codeの設定: グローバル設定から権限管理まで"
emoji: "⚙️"
type: "tech"
topics: ["Claude", "AI", "CLI", "開発ツール"]
published: true
---
# 🎨 Claude Codeの設定とカスタマイズ

Claude Codeはニーズに合わせて動作を設定するための様々な設定を提供しています。ターミナルで`claude config`を実行するか、インタラクティブREPLを使用する際に`/config`コマンドを実行することでClaude Codeを設定できます。

## 設定の階層構造

新しい`settings.json`ファイルは、階層的な設定を通じてClaude Codeを構成するための公式メカニズムです：

* **ユーザー設定**は`~/.claude/settings.json`で定義され、すべてのプロジェクトに適用されます。
* **プロジェクト設定**はプロジェクトディレクトリの`.claude/settings.json`（共有設定用）と`.claude/settings.local.json`（ローカルプロジェクト設定用）に保存されます。Claude Codeは作成時に`.claude/settings.local.json`をgitで無視するよう設定します。
* Claude Codeのエンタープライズデプロイメントでは、**エンタープライズ管理ポリシー設定**もサポートしています。これらはユーザーおよびプロジェクト設定よりも優先されます。システム管理者はmacOSでは`/Library/Application Support/ClaudeCode/policies.json`に、LinuxおよびWSL経由のWindowsでは`/etc/claude-code/policies.json`にポリシーをデプロイできます。

```json
{
  "permissions": {
    "allow": [
      "Bash(npm run lint)",
      "Bash(npm run test:*)",
      "Read(~/.zshrc)"
    ],
    "deny": [
      "Bash(curl:*)"
    ]
  },
  "env": {
    "CLAUDE_CODE_ENABLE_TELEMETRY": "1",
    "OTEL_METRICS_EXPORTER": "otlp"
  }
}
```

### 利用可能な設定

`settings.json`は多くのオプションをサポートしています：

| キー                    | 説明                                                               | 例                               |
| :-------------------- | :--------------------------------------------------------------- | :------------------------------ |
| `apiKeyHelper`        | Anthropic APIキーを生成するカスタムスクリプト                                    | `/bin/generate_temp_api_key.sh` |
| `cleanupPeriodDays`   | チャット履歴をローカルに保持する期間（デフォルト：30日）                                    | `20`                            |
| `env`                 | すべてのセッションに適用される環境変数                                              | `{"FOO": "bar"}`                |
| `includeCoAuthoredBy` | gitコミットとプルリクエストに`co-authored-by Claude`の署名を含めるかどうか（デフォルト：`true`） | `false`                         |

### 設定の優先順位

設定は以下の優先順位で適用されます：

1. エンタープライズポリシー
2. コマンドライン引数
3. ローカルプロジェクト設定
4. 共有プロジェクト設定
5. ユーザー設定

## 設定オプション

Claude Codeはグローバル設定とプロジェクトレベルの設定をサポートしています。

設定を管理するには、以下のコマンドを使用します：

* 設定の一覧表示：`claude config list`
* 設定の確認：`claude config get <key>`
* 設定の変更：`claude config set <key> <value>`
* 設定への追加（リスト用）：`claude config add <key> <value>`
* 設定からの削除（リスト用）：`claude config remove <key> <value>`

デフォルトでは`config`はプロジェクト設定を変更します。グローバル設定を管理するには、`--global`（または`-g`）フラグを使用します。

### グローバル設定

グローバル設定を設定するには、`claude config set -g <key> <value>`を使用します：

| キー                      | 説明                                      | 例                                                                       |
| :---------------------- | :-------------------------------------- | :---------------------------------------------------------------------- |
| `autoUpdaterStatus`     | 自動更新を有効または無効にする（デフォルト：`enabled`）        | `disabled`                                                              |
| `preferredNotifChannel` | 通知を受け取る場所（デフォルト：`iterm2`）               | `iterm2`、`iterm2_with_bell`、`terminal_bell`、または`notifications_disabled` |
| `theme`                 | カラーテーマ                                  | `dark`、`light`、`light-daltonized`、または`dark-daltonized`                  |
| `verbose`               | bashとコマンドの出力を完全に表示するかどうか（デフォルト：`false`） | `true`                                                                  |

グローバル設定を`settings.json`に移行するプロセスを進めています。

## 権限

`/allowed-tools`を使用してClaude Codeのツール権限を管理できます。このUIはすべての権限ルールとそれらが取得されるsettings.jsonファイルを一覧表示します。

* **許可**ルールは、Claude Codeが指定されたツールを手動承認なしで使用できるようにします。
* **拒否**ルールは、Claude Codeが指定されたツールを使用できないようにします。拒否ルールは許可ルールよりも優先されます。

権限ルールは`Tool(optional-specifier)`の形式を使用します。

例えば、`WebFetch`を許可ルールのリストに追加すると、ユーザー承認を必要とせずにウェブフェッチツールの使用が許可されます。[Claudeが利用できるツール](/ja/docs/claude-code/security#tools-available-to-claude)のリストを参照してください（括弧内の名前が提供されている場合はその名前を使用します）。

一部のツールでは、より細かい権限制御のためにオプションの指定子を使用します。例えば、`WebFetch(domain:example.com)`を含む許可ルールは、example.comへのフェッチを許可しますが、他のURLへのフェッチは許可しません。

Bashルールは`Bash(npm run build)`のような完全一致、または`Bash(npm run test:*)`のように`:*`で終わる場合はプレフィックス一致になります。

`Read()`と`Edit()`ルールは[gitignore](https://git-scm.com/docs/gitignore)仕様に従います。パターンは`.claude/settings.json`を含むディレクトリを基準に解決されます。絶対パスを参照するには`//`を使用します。ホームディレクトリを基準とするパスには`~/`を使用します。例えば`Read(//tmp/build_cache)`や`Edit(~/.zshrc)`などです。Claudeは、Grep、Glob、LSなどの他のファイル関連ツールにもReadおよびEditルールを適用するよう最善の努力をします。

MCPツール名は`mcp__server_name__tool_name`の形式に従います：

* `server_name`はClaude Codeで設定されたMCPサーバーの名前です
* `tool_name`はそのサーバーが提供する特定のツールです

その他の例：

| ルール                                  | 説明                                                                |
| :----------------------------------- | :---------------------------------------------------------------- |
| `Bash(npm run build)`                | 正確なBashコマンド`npm run build`に一致します。                                 |
| `Bash(npm run test:*)`               | `npm run test`で始まるBashコマンドに一致します。コマンドセパレータの処理に関する注意点を以下に参照してください。 |
| `Edit(~/.zshrc)`                     | `~/.zshrc`ファイルに一致します。                                             |
| `Read(node_modules/**)`              | 任意の`node_modules`ディレクトリに一致します。                                    |
| `mcp__puppeteer__puppeteer_navigate` | `puppeteer` MCPサーバーの`puppeteer_navigate`ツールに一致します。                |
| `WebFetch(domain:example.com)`       | example.comへのフェッチリクエストに一致します                                      |

> **Tip**: Claude Codeはコマンドセパレータ（`&&`など）を認識するため、`Bash(safe-cmd:*)`のようなプレフィックス一致ルールでは、`safe-cmd && other-cmd`のようなコマンドを実行する権限は与えられません

## 自動更新の権限オプション

Claude Codeがグローバルnpmプレフィックスディレクトリ（自動更新に必要）に書き込むための十分な権限がないことを検出すると、このドキュメントページを指す警告が表示されます。自動更新の問題に関する詳細なソリューションについては、[トラブルシューティングガイド](/ja/docs/claude-code/troubleshooting#auto-updater-issues)を参照してください。

### 推奨：ユーザーが書き込み可能な新しいnpmプレフィックスを作成する

```bash
# まず、既存のグローバルパッケージのリストを後で移行するために保存します
npm list -g --depth=0 > ~/npm-global-packages.txt

# グローバルパッケージ用のディレクトリを作成します
mkdir -p ~/.npm-global

# 新しいディレクトリパスを使用するようにnpmを設定します
npm config set prefix ~/.npm-global

# 注意：~/.bashrcを使用しているシェルに応じて~/.zshrc、~/.profile、または他の適切なファイルに置き換えてください
echo 'export PATH=~/.npm-global/bin:$PATH' >> ~/.bashrc

# 新しいPATH設定を適用します
source ~/.bashrc

# 新しい場所にClaude Codeを再インストールします
npm install -g @anthropic-ai/claude-code

# オプション：以前のグローバルパッケージを新しい場所に再インストールします
# ~/npm-global-packages.txtを見て、保持したいパッケージをインストールします
# npm install -g package1 package2 package3...
```

**このオプションを推奨する理由：**

* システムディレクトリの権限を変更する必要がありません
* グローバルnpmパッケージ用のクリーンで専用の場所を作成します
* セキュリティのベストプラクティスに従います

Claude Codeは積極的に開発中であるため、上記の推奨オプションを使用して自動更新を設定することをお勧めします。

### 自動更新の無効化

権限を修正する代わりに自動更新を無効にしたい場合は、次のコマンドを使用できます：

```bash
claude config set -g autoUpdaterStatus disabled
```

## ターミナル設定の最適化

Claude Codeは、ターミナルが適切に設定されている場合に最も効果的に動作します。以下のガイドラインに従って、エクスペリエンスを最適化してください。

**サポートされているシェル**：

* Bash
* Zsh
* Fish

### テーマと外観

Claudeはターミナルのテーマを制御できません。それはターミナルアプリケーションによって処理されます。オンボーディング中または`/config`コマンドを使用していつでも、Claude Codeのテーマをターミナルに合わせることができます。

### 改行

Claude Codeに改行を入力するためのいくつかのオプションがあります：

* **クイックエスケープ**：`\`に続けてEnterを押して改行を作成
* **キーボードショートカット**：適切な設定でOption+Enter（Meta+Enter）を押す

ターミナルでOption+Enterを設定するには：

**Mac Terminal.appの場合：**

1. 設定 → プロファイル → キーボードを開く
2. 「Option as Meta Key を使用」にチェックを入れる

**iTerm2とVSCodeターミナルの場合：**

1. 設定 → プロファイル → キーを開く
2. 一般の下で、左/右Optionキーを「Esc+」に設定

**iTerm2とVSCodeユーザーへのヒント**：Claude Code内で`/terminal-setup`を実行して、より直感的な代替手段としてShift+Enterを自動的に設定します。

### 通知設定

適切な通知設定で、Claudeがタスクを完了したときを見逃さないようにしましょう：

#### ターミナルベル通知

タスク完了時のサウンドアラートを有効にする：

```sh
claude config set --global preferredNotifChannel terminal_bell
```

**macOSユーザーの場合**：システム設定 → 通知 → \[ターミナルアプリ]で通知権限を有効にすることを忘れないでください。

#### iTerm 2システム通知

タスク完了時にiTerm 2アラートを表示する：

1. iTerm 2の環境設定を開く
2. プロファイル → ターミナルに移動
3. 「ベルを無音にする」と「フィルターアラート」→「エスケープシーケンス生成アラートを送信」を有効にする
4. 希望する通知遅延を設定する

これらの通知はiTerm 2に固有のものであり、デフォルトのmacOSターミナルでは利用できないことに注意してください。

### 大量の入力の処理

広範なコードや長い指示を扱う場合：

* **直接貼り付けを避ける**：Claude Codeは非常に長い貼り付けられたコンテンツで苦労する場合があります
* **ファイルベースのワークフローを使用する**：コンテンツをファイルに書き込み、Claudeに読み取りを依頼する
* **VS Codeの制限に注意する**：VS Codeターミナルは特に長い貼り付けを切り詰める傾向があります

### Vimモード

Claude Codeは`/vim`で有効にするか、`/config`で設定できるVimキーバインディングのサブセットをサポートしています。

サポートされているサブセットには以下が含まれます：

* モード切り替え：`Esc`（NORMALモードへ）、`i`/`I`、`a`/`A`、`o`/`O`（INSERTモードへ）
* ナビゲーション：`h`/`j`/`k`/`l`、`w`/`e`/`b`、`0`/`$`/`^`、`gg`/`G`
* 編集：`x`、`dw`/`de`/`db`/`dd`/`D`、`cw`/`ce`/`cb`/`cc`/`C`、`.`（繰り返し）

## 環境変数

Claude Codeは、その動作を制御するために以下の環境変数をサポートしています：

> **Note**: すべての環境変数は`settings.json`でも設定できます。これは各セッションの環境変数を自動的に設定したり、チーム全体や組織全体に環境変数のセットをロールアウトしたりするのに便利です。

| 変数                                         | 目的                                                                                                 |
| :----------------------------------------- | :------------------------------------------------------------------------------------------------- |
| `ANTHROPIC_AUTH_TOKEN`                     | `Authorization`および`Proxy-Authorization`ヘッダーのカスタム値（ここで設定した値には`Bearer `が前に付きます）                      |
| `ANTHROPIC_CUSTOM_HEADERS`                 | リクエストに追加したいカスタムヘッダー（`Name: Value`形式）                                                               |
| `ANTHROPIC_MODEL`                          | デフォルトモデルの名前                                                                                        |
| `ANTHROPIC_SMALL_FAST_MODEL`               | Haikuクラスモデルの名前                                                                                     |
| `BASH_DEFAULT_TIMEOUT_MS`                  | 長時間実行されるbashコマンドのデフォルトタイムアウト                                                                       |
| `BASH_MAX_TIMEOUT_MS`                      | 長時間実行されるbashコマンドに対してモデルが設定できる最大タイムアウト                                                              |
| `BASH_MAX_OUTPUT_LENGTH`                   | bash出力が中間で切り詰められる前の最大文字数                                                                           |
| `CLAUDE_CODE_API_KEY_HELPER_TTL_MS`        | 認証情報を更新する間隔（`apiKeyHelper`使用時）                                                                     |
| `CLAUDE_CODE_USE_BEDROCK`                  | Bedrockを使用する                   |
| `CLAUDE_CODE_USE_VERTEX`                   | Vertexを使用する                    |
| `CLAUDE_CODE_SKIP_VERTEX_AUTH`             | VertexのためのGoogle認証をスキップする（例：プロキシ使用時）                                                               |
| `CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC` | `DISABLE_AUTOUPDATER`、`DISABLE_BUG_COMMAND`、`DISABLE_ERROR_REPORTING`、および`DISABLE_TELEMETRY`の設定と同等 |
| `DISABLE_AUTOUPDATER`                      | `1`に設定すると自動更新を無効にします                                                                               |
| `DISABLE_BUG_COMMAND`                      | `1`に設定すると`/bug`コマンドを無効にします                                                                         |
| `DISABLE_COST_WARNINGS`                    | `1`に設定するとコスト警告メッセージを無効にします                                                                         |
| `DISABLE_ERROR_REPORTING`                  | `1`に設定するとSentryエラーレポートをオプトアウトします                                                                   |
| `DISABLE_TELEMETRY`                        | `1`に設定するとStatsigテレメトリをオプトアウトします（Statsigイベントにはコード、ファイルパス、bashコマンドなどのユーザーデータは含まれないことに注意してください）       |
| `HTTP_PROXY`                               | ネットワーク接続用のHTTPプロキシサーバーを指定します                                                                       |
| `HTTPS_PROXY`                              | ネットワーク接続用のHTTPSプロキシサーバーを指定します                                                                      |
| `MAX_THINKING_TOKENS`                      | モデルの思考予算を強制します                                                                                     |
| `MCP_TIMEOUT`                              | MCPサーバー起動のタイムアウト（ミリ秒）                                                                              |
| `MCP_TOOL_TIMEOUT`                         | MCPツール実行のタイムアウト（ミリ秒）                                                                               |


---

## 🔗 参考リンク

- [Claude Code公式ドキュメント（日本語版）](https://docs.anthropic.com/ja/docs/claude-code)
- [設定の詳細](https://docs.anthropic.com/ja/docs/claude-code/settings)
- [トラブルシューティング](https://docs.anthropic.com/ja/docs/claude-code/troubleshooting)