---
title: "Discord でポチるだけ！OpenClaw で Zenn 記事公開 → X 拡散を完全自動化する"
emoji: "🤖"
type: "tech"
topics: ["OpenClaw", "Zenn", "Discord", "自動化", "生産性"]
published: false
publication_name: "iwakenlab_book"
---

# はじめに

Zenn で記事を書くとき、こんな面倒さを感じたことはありませんか？

- **Markdown を書いて → GitHub に Push → プレビュー確認 → 公開**
- **公開したら手動で X（Twitter）にリンクをツイート**
- **気づけば記事執筆より作業に時間を取られている**

そこで、**Discord のボタンを押すだけで Zenn 記事を公開 → X で拡散まで完全自動化**する仕組みを OpenClaw で作りました。

本記事では、この自動化フローの全体像と実装方法を紹介します。

## こんな人におすすめ

- Zenn 記事執筆を効率化したい
- Discord を操作拠点にしている
- OpenClaw を活用して自動化したい
- AI アシスタントで記事作成から公開まで完結させたい

---

# 環境・前提条件

## 必要なもの

- **OpenClaw** — AI アシスタント（Claude ベース）
  - Discord 連携設定済み
  - GitHub 操作権限あり（`gh` CLI）
- **Zenn アカウント**
  - GitHub リポジトリ連携済み
  - Publication（出版先）設定済み
- **X (Twitter) API**（オプション）
  - Developer Account で API キー取得
  - ツイート投稿権限あり

## 前提知識

- Zenn の GitHub 連携方式（articles フォルダに Markdown を置くと自動同期）
- Discord の Modal / Button UI（OpenClaw の `message` tool で実装可能）
- OpenClaw の Skill 作成方法

---

# Step 1: Zenn 記事作成の自動化

## 1-1. Zenn リポジトリ構造

Zenn は GitHub リポジトリの `articles/` フォルダに Markdown を置くと自動同期されます。

```
ZennArticle/
├── articles/
│   └── your-article.md
└── books/
```

記事ファイルの構造：

```yaml
---
title: "記事タイトル"
emoji: "🔥"
type: "tech" # or "idea"
topics: ["topic1", "topic2", "topic3"]
published: false # true にすると公開
publication_name: "your_publication"
---

# 本文

ここに Markdown で記事を書く
```

## 1-2. zenn-article-writer Skill

OpenClaw Skill として `zenn-article-writer` を作成しました。

**機能:**
- 記事テーマから Markdown を生成
- GitHub に Feature Branch → PR 作成
- Zenn Dashboard でプレビュー確認
- `published: true` に変更して公開

**ディレクトリ構成:**

```
skills/zenn-article-writer/
├── SKILL.md           # スキル定義
└── README.md
```

**SKILL.md の要点:**

```markdown
## Workflow

1. 記事アイデアを特定
2. Markdown ファイルを作成（published: false）
3. Feature Branch → PR 作成
4. Zenn Dashboard でプレビュー
5. published: true に変更 → 公開
```

## 1-3. Discord から記事作成を指示

Discord で以下のように指示するだけ：

```
@ai-iwaken 「OpenClaw 自動化事例」で Zenn 記事を書いて
```

すると OpenClaw が：
1. 記事内容を生成
2. GitHub に Feature Branch 作成
3. PR を作成してリンクを返す

```
✅ PR 作成しました！
https://github.com/iwaken71/ZennArticle/pull/42
Zenn Dashboard で確認してください。
```

---

# Step 2: X 拡散の自動化

## 2-1. X API 設定

X Developer Portal で API キーを取得：

1. https://developer.x.com でプロジェクト作成
2. API Key & Secret を取得
3. Access Token & Secret を生成（Read and Write 権限）

**環境変数に設定:**

```bash
export TWITTER_API_KEY="your_api_key"
export TWITTER_API_SECRET="your_api_secret"
export TWITTER_ACCESS_TOKEN="your_access_token"
export TWITTER_ACCESS_SECRET="your_access_secret"
```

## 2-2. ツイート投稿スクリプト

OpenClaw から X API を叩くシンプルなスクリプト：

```python
# skills/zenn-article-writer/tweet.py
import os
import tweepy

api_key = os.getenv("TWITTER_API_KEY")
api_secret = os.getenv("TWITTER_API_SECRET")
access_token = os.getenv("TWITTER_ACCESS_TOKEN")
access_secret = os.getenv("TWITTER_ACCESS_SECRET")

auth = tweepy.OAuthHandler(api_key, api_secret)
auth.set_access_token(access_token, access_secret)
api = tweepy.API(auth)

def post_tweet(text):
    api.update_status(text)
    print("✅ ツイート投稿成功")

if __name__ == "__main__":
    import sys
    post_tweet(sys.argv[1])
```

**実行例:**

```bash
python tweet.py "新しい記事を公開しました！\n\nDiscord でポチるだけ！OpenClaw で Zenn 記事公開 → X 拡散を完全自動化する\nhttps://zenn.dev/iwaken71/articles/..."
```

## 2-3. OpenClaw から自動実行

記事公開後、OpenClaw が自動でツイート：

```bash
cd /Users/iwaken/.openclaw/workspace/skills/zenn-article-writer
python tweet.py "記事公開しました！ $URL"
```

---

# Step 3: Discord Modal で一発公開

## 3-1. Discord Modal とは

Discord の Modal は、ユーザー入力を受け取る UI です。

OpenClaw の `message` tool で Modal を実装可能：

```json
{
  "action": "send",
  "channel": "discord",
  "target": "channel_id",
  "components": {
    "modal": {
      "title": "Zenn 記事公開",
      "fields": [
        {
          "type": "text",
          "label": "記事タイトル",
          "name": "title",
          "required": true
        },
        {
          "type": "text",
          "label": "記事 URL",
          "name": "url",
          "required": true
        }
      ]
    }
  }
}
```

## 3-2. ワークフロー全体

1. **Discord でボタンをクリック** → Modal 表示
2. **記事タイトルと URL を入力** → Submit
3. **OpenClaw が自動実行:**
   - GitHub で `published: true` に変更 → Push
   - X に記事リンクを投稿
   - Discord に完了通知

## 3-3. 実装例（簡略版）

```markdown
# Discord で「記事公開」ボタンを作成
→ Modal 表示
→ ユーザーが記事情報を入力
→ OpenClaw が自動で:
  1. GitHub の記事ファイルを編集（published: true）
  2. Commit & Push
  3. X にツイート投稿
  4. Discord に完了通知
```

**Discord での見た目:**

```
🤖 ai-iwaken
記事を公開しますか？

[📝 記事公開] ← クリックすると Modal 表示
```

**Modal 入力後:**

```
✅ 記事を公開しました！
🔗 https://zenn.dev/iwaken71/articles/...
🐦 X にも投稿済みです
```

---

# まとめ

**この自動化で得られるもの:**

- **時短:** Discord のボタン1つで公開 → 拡散まで完結
- **集中:** 記事執筆に集中でき、作業負荷を削減
- **再現性:** 一度作れば何度でも使える

**OpenClaw の強み:**

- **AI アシスタントが全体を管理** — 人間は指示するだけ
- **Discord を操作拠点にできる** — CLI に触れる必要なし
- **Skill 化で再利用可能** — 一度作れば別の自動化にも応用可能

Zenn 記事執筆の面倒な作業を全部自動化して、**創作活動そのものに集中しましょう！**

---

# 参考リンク

- [OpenClaw 公式ドキュメント](https://docs.openclaw.ai)
- [Zenn と GitHub の連携方法](https://zenn.dev/zenn/articles/connect-to-github)
- [X (Twitter) API Documentation](https://developer.x.com/en/docs)
- [Discord Developer Portal](https://discord.com/developers/docs)

---

:::message
この記事は OpenClaw（AI アシスタント）によって執筆されました。
:::
