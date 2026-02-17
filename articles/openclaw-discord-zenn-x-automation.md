---
title: "OpenClaw で Zenn 記事公開 → X 拡散を完全自動化する"
emoji: "🤖"
type: "tech"
topics: ["OpenClaw", "Zenn", "X", "自動化", "GitHub"]
published: false
publication_name: "iwakenlab_book"
---

# はじめに

技術記事を書くのは楽しいけれど、公開作業や SNS 拡散が面倒……そんな経験ありませんか？

- 記事を GitHub に push して PR 作って……
- 記事を公開したら X (Twitter) でツイート文を考えて投稿して……
- こういう繰り返し作業、自動化できたらいいのに……

**OpenClaw の Skill 機能を使えば、記事執筆から X 拡散までを完全自動化できます。**

この記事では、実際に構築した **「Zenn 記事公開 → X 投稿」の完全自動化フロー**を解説します。

# Zenn とは？なぜ自動化に向いているのか

Zenn は **GitHub で記事を管理できる技術ブログプラットフォーム**です。

**Zenn が自動化に最適な理由：**

1. **Git ベースで記事管理**
   - Markdown ファイルで記事を書く
   - バージョン管理が簡単
   - ローカルでも編集可能

2. **GitHub と連携**
   - GitHub リポジトリと自動同期
   - PR ベースのワークフローが使える
   - master ブランチにマージすれば自動公開

3. **プログラマブルな公開フロー**
   - `published: true/false` で公開制御
   - 下書き → 公開を Git commit で管理
   - CI/CD との統合も可能

**つまり：記事公開のすべてのステップを自動化できる**

他のプラットフォーム（note、Qiita など）は Web UI が必須で自動化が難しいのに対し、Zenn は **完全に Git で管理できるため AI による自動化に最適**です。

# 実現できること

AI アシスタントに話しかけるだけで：

```
今日の学び：OpenClaw の Skill 機能便利すぎる！
```

↓ 5分後

1. ✅ Zenn 記事が執筆される
2. ✅ GitHub に PR が作成される
3. ✅ 記事が公開される
4. ✅ X にツイートが投稿される

これが自動で完了します。

**トリガー方法（例）:**
- **Discord** から話しかける（本記事の例）
- **Slack** コマンドで実行
- **Telegram** bot に話しかける
- **CLI** から実行
- **Heartbeat** で定期的に実行

# 前提知識

## 必要な環境

- **OpenClaw がインストールされていること**
- **GitHub アカウント**
- **Zenn アカウント**（GitHub 連携済み）
- **X (Twitter) アカウント**
- **Chrome** + OpenClaw Browser Relay 拡張機能

## Zenn と GitHub の連携

Zenn で記事を管理するには、GitHub リポジトリとの連携が必要です：

1. Zenn にログイン: https://zenn.dev
2. 「GitHub からのデプロイ」を選択
3. GitHub リポジトリを作成・連携
4. リポジトリに `articles/` フォルダを作成

詳細: https://zenn.dev/zenn/articles/connect-to-github

これで GitHub の master ブランチにマージすれば、自動的に Zenn に公開されます。

## OpenClaw の基本セットアップ

OpenClaw の基本的なインストールとセットアップは完了している前提で進めます。

**インターフェース（例）:**
- Discord チャンネル（本記事の例）
- Slack ワークスペース
- Telegram bot
- CLI から直接実行

どのインターフェースでも同じ Skill を使えます。

# Skill の構成

このワークフローは 3 つの Skill で構成されます：

## 1. zenn-article-writer

**役割:** Zenn 記事を執筆し、GitHub PR を作成・マージ・公開

**機能:**
- 記事のアイデアから Markdown 記事を生成
- YAML frontmatter（タイトル、emoji、topics）を自動設定
- Git feature ブランチ作成 → PR 作成 → マージ
- `published: true` に変更して公開

**出力:**
- `articles/<slug>.md` ファイル
- GitHub PR URL
- 公開済み Zenn 記事 URL

## 2. zenn-to-x

**役割:** Zenn 記事から X 用のツイート文を自動生成

**機能:**
- 記事のタイトル、topics、URL から最適なツイート文を生成
- 280文字以内に収める
- ハッシュタグを自動付与（#OpenClaw #Zenn など）

**出力形式:**
```
📝 新しい記事を書きました！

[OpenClaw] Discord でポチるだけ！Zenn 記事公開 → X 拡散を完全自動化する

OpenClaw 初心者向けに、Discord から Zenn 記事公開・X 投稿までを自動化する方法を解説しました。

#OpenClaw #Discord #Zenn #X #自動化

https://zenn.dev/iwaken71/articles/openclaw-discord-zenn-x-automation
```

## 3. x-post

**役割:** ブラウザ自動化で X に投稿

**機能:**
- Chrome の OpenClaw Browser Relay 拡張機能を使用
- twitter.com/compose/tweet を開く
- ツイート文を入力
- 投稿前に確認（誤爆防止）
- Post ボタンをクリックして投稿

**安全機能:**
- 280文字制限チェック
- 投稿前の確認プロンプト
- エラーハンドリング（未ログイン、拡張機能未接続など）

# 実装手順

## Step 1: zenn-article-writer Skill を作成

まず、Zenn 記事執筆・公開の Skill を作成します。

```bash
cd ~/.openclaw/workspace/skills
mkdir -p zenn-article-writer
```

`skills/zenn-article-writer/SKILL.md` を作成：

```yaml
---
name: zenn-article-writer
description: Write and publish Zenn technical articles from daily work. Use when creating Zenn articles from work logs, experiences, or technical topics.
---

# Zenn Article Writer

Create technical articles for Zenn from daily work and experiences.

## Repository

- **Path:** `/Users/<username>/.openclaw/workspace/ZennArticle`
- **Remote:** `git@github.com:<username>/ZennArticle.git`

## Workflow

1. Identify article idea
2. Create article with frontmatter
3. Create feature branch and PR
4. Preview on Zenn Dashboard (merge as draft)
5. Publish (`published: true`)

(詳細は省略 — SKILL.md に記載)
```

**ポイント:**
- GitHub リポジトリパスを自分の環境に合わせる
- Zenn と GitHub の連携設定が必要

## Step 2: zenn-to-x Skill を作成

次に、Zenn 記事から X ツイートを生成する Skill を作成します。

```bash
mkdir -p ~/.openclaw/workspace/skills/zenn-to-x
```

`skills/zenn-to-x/SKILL.md`:

```yaml
---
name: zenn-to-x
description: Generate X (Twitter) posts for published Zenn articles. Use after publishing a Zenn article to announce it on social media.
---

# Zenn to X

Generate X (Twitter) posts to announce published Zenn articles.

## Format

📝 新しい記事を書きました！

[Category] Article Title

Brief description (1-2 sentences)

#Topic1 #Topic2 #Topic3

https://zenn.dev/<username>/articles/<slug>

(詳細は省略)
```

## Step 3: x-post Skill を作成

最後に、X 投稿を自動化する Skill を作成します。

```bash
mkdir -p ~/.openclaw/workspace/skills/x-post
```

`skills/x-post/SKILL.md`:

```yaml
---
name: x-post
description: Post tweets to X (Twitter) via browser automation. Use when asked to post, tweet, or publish content to X/Twitter.
---

# X Post

Automate posting tweets to X (Twitter) using browser automation.

## Prerequisites

- Chrome with OpenClaw Browser Relay extension
- User logged into X (twitter.com) in Chrome

## Workflow

1. Receive tweet content
2. Open twitter.com/compose/tweet
3. Take snapshot to identify textarea
4. Type tweet content
5. Ask for confirmation
6. Click Post button
7. Verify success

(詳細は省略)
```

**重要:** Chrome で OpenClaw Browser Relay 拡張機能を有効にし、X にログインしておく必要があります。

## Step 4: Skills のテスト

各 Skill を個別にテストします：

**zenn-article-writer のテスト:**

```
@AI執事 OpenClaw の便利な使い方について Zenn 記事を書いて
```

→ 記事が作成され、GitHub PR が作成されることを確認

**zenn-to-x のテスト:**

```
@AI執事 この Zenn 記事のツイート文を生成して: https://zenn.dev/iwaken71/articles/example
```

→ ツイート文が生成されることを確認

**x-post のテスト:**

```
@AI執事 このツイートを投稿して: 📝 テスト投稿です #OpenClaw
```

→ X にツイートが投稿されることを確認（投稿前に確認プロンプトが出る）

# 使い方

## 基本的な使い方（Discord の例）

AI アシスタントに話しかけるだけ：

**Discord の場合:**
```
@AI執事 今日の学び：Tailscale と SSH でリモートアクセスが超簡単になった！
```

**Slack の場合:**
```
/openclaw Zenn記事にして: Tailscale と SSH でリモートアクセスが超簡単になった
```

**Telegram の場合:**
```
今日の学びを Zenn 記事にまとめて
```

**CLI から実行:**
```bash
openclaw run "今日の学びを Zenn 記事にして"
```

すると：

1. **記事執筆**: 体験をもとに記事が執筆される
2. **PR 作成**: GitHub に feature ブランチと PR が作成される
3. **下書き確認**: Zenn Dashboard で下書きをプレビュー
4. **公開**: `published: true` に変更して公開
5. **ツイート生成**: 記事 URL から最適なツイート文を生成
6. **X 投稿**: ブラウザ自動化で X に投稿（確認プロンプト付き）

## 段階的な使い方

完全自動化が不安な場合は、段階的に実行できます：

**ステップ 1: 記事執筆のみ**

```
OpenClaw の Skill 機能について Zenn 記事を書いて（下書きのみ）
```

**ステップ 2: 下書き確認**

Zenn Dashboard で内容を確認し、必要に応じて編集

**ステップ 3: 公開**

```
記事を公開して
```

**ステップ 4: X 投稿**

```
この記事を X で拡散して
```

# トラブルシューティング

## X 投稿がうまくいかない

**症状:** ブラウザが開かない、または投稿されない

**解決策:**
1. Chrome で OpenClaw Browser Relay 拡張機能が有効か確認
2. X (twitter.com) にログインしているか確認
3. Browser Relay のタブが「attached」状態か確認（toolbar アイコンをクリックして badge ON）

## 記事が Zenn に反映されない

**症状:** GitHub にマージしたが Zenn に表示されない

**解決策:**
1. Zenn と GitHub の連携設定を確認
2. 2〜5 分待ってから Zenn Dashboard をリロード
3. GitHub リポジトリの master ブランチに記事ファイルが存在するか確認

## PR 作成に失敗する

**症状:** `gh pr create` でエラーが出る

**解決策:**
1. GitHub CLI (`gh`) がインストールされているか確認
2. `gh auth status` で認証状態を確認
3. リポジトリの SSH URL が正しいか確認（`git remote -v`）

# 応用例

## 他のプラットフォームへの展開

同様の Skill を作成すれば、他のプラットフォームへの自動投稿も可能：

**note:**
- `note-article-writer`: note API で記事公開
- `note-to-x`: note 記事から X ツイート生成
- `x-post`: 既存の Skill を再利用

**Qiita:**
- Qiita API で記事投稿
- 同様のワークフローを構築

**個人ブログ:**
- Hugo, Jekyll, Next.js などの静的サイト
- Git push → Vercel/Netlify デプロイ → X 投稿

## 定期的な振り返り記事

cron と組み合わせて、週次で振り返り記事を自動生成：

```yaml
# .openclaw/config.yaml
cron:
  - name: weekly-reflection
    schedule: "0 9 * * 1"  # 毎週月曜 9:00
    command: "今週の学びを Zenn 記事にまとめて"
```

## さまざまなトリガー方法

OpenClaw の柔軟性を活かして、さまざまな方法で記事作成をトリガーできます：

**メッセージングプラットフォーム:**
- Discord: `@AI執事 Zenn 記事にして`
- Slack: `/openclaw zenn`
- Telegram: bot に話しかける
- iMessage: SMS から実行

**自動化:**
- Heartbeat: 定期的にチェック
- Git hook: commit メッセージから記事生成
- Webhook: 外部イベントをトリガー

**CLI:**
- ローカルで直接実行
- スクリプトから呼び出し

# まとめ

OpenClaw の Skill 機能を使えば、**Zenn 記事公開 → X 拡散までを完全自動化**できます。

**なぜ Zenn が自動化に最適か:**
- ✅ GitHub で記事を管理できる
- ✅ Git ベースのワークフロー
- ✅ プログラマブルな公開制御
- ✅ → AI による完全自動化が可能！

**得られるメリット:**
- ✅ 記事執筆のハードルが下がる（思いついたらすぐ記事化）
- ✅ 公開・拡散の手間が激減（コピペ作業ゼロ）
- ✅ ナレッジ発信の習慣化（継続しやすい）
- ✅ 再利用可能（Skill は何度でも使える）
- ✅ インターフェース非依存（Discord, Slack, CLI など自由に選べる）

**今後の展開:**
- X API 統合で完全自動投稿（確認なし）
- 画像生成 AI と連携してアイキャッチ画像も自動生成
- note、Qiita、個人ブログへの同時投稿
- 音声入力からの記事生成

OpenClaw を使えば、技術的障壁を下げてナレッジ発信を加速できます。ぜひ試してみてください！

# 参考リンク

- [OpenClaw 公式ドキュメント](https://docs.openclaw.ai)
- [OpenClaw GitHub](https://github.com/openclaw/openclaw)
- [Zenn と GitHub の連携方法](https://zenn.dev/zenn/articles/connect-to-github)
- [OpenClaw Browser Relay 拡張機能](https://docs.openclaw.ai/tools/browser)

---

:::message
この記事は OpenClaw（AI アシスタント）によって執筆されました。
:::
