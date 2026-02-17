---
title: "[OpenClaw] GitHub で AI アシスタントのワークスペースを管理する"
emoji: "💾"
type: "tech"
topics: ["OpenClaw", "GitHub", "Git", "バックアップ", "初心者"]
published: true
publication_name: "iwakenlab_book"
---

# はじめに

OpenClaw を使い始めると、ワークスペースに大切な情報が溜まっていきます。

- `MEMORY.md` — AI との会話履歴や記憶
- `USER.md` — あなたのプロフィール
- `SOUL.md` — AI のキャラクター設定
- `skills/` — カスタム Skill
- `scripts/` — 便利スクリプト

**もし Mac が壊れたら、これらは全て失われます。**

この記事では、**GitHub を使ってワークスペースを安全にバックアップする方法**を、プログラミング経験がない方にも分かるように解説します。

## 完成イメージ

- ワークスペースが GitHub に自動バックアップされる
- 変更履歴が残る（いつ何を変更したか分かる）
- 複数の PC から同じ設定を使える
- 万が一の時も復元できる

# なぜ GitHub？

| 方法 | メリット | デメリット |
|------|----------|------------|
| **GitHub（採用）** | 無料・履歴管理・複数PC対応 | 初回設定がやや複雑 |
| iCloud / Dropbox | 簡単 | 履歴管理が弱い・競合しやすい |
| Time Machine | Mac 標準 | 外付けHDD必要・履歴が見づらい |

GitHub は**バージョン管理システム**で、「いつ・誰が・何を変更したか」を全て記録してくれます。

# 環境

- Mac（macOS）
- OpenClaw インストール済み
- GitHub アカウント（なければ作成）

**所要時間:** 約10分

# 手順

## ステップ1: GitHub アカウントを作成

すでにアカウントがある方は飛ばしてください。

1. <https://github.com/> にアクセス
2. **Sign up** をクリック
3. メールアドレス・ユーザー名・パスワードを入力
4. メール認証を完了

## ステップ2: GitHub CLI をインストール

ターミナルで以下を実行：

```bash
brew install gh
```

インストール後、GitHub にログイン：

```bash
gh auth login
```

画面の指示に従って：
- `GitHub.com` を選択
- `HTTPS` を選択
- `Login with a web browser` を選択
- 表示されたコードをコピー
- ブラウザで認証

成功すると `✓ Logged in as ユーザー名` と表示されます。

## ステップ3: ワークスペースを Git で管理

OpenClaw のワークスペースに移動：

```bash
cd ~/.openclaw/workspace
```

現在の状態を確認：

```bash
ls -la
```

`MEMORY.md`、`USER.md`、`SOUL.md` などが見えるはずです。

### Git リポジトリとして初期化

すでに `.git` フォルダがある場合はスキップしてください。

```bash
git init
```

これで「履歴を記録できる」状態になりました。

### 除外ファイルを設定

一部のファイルはバックアップ不要です。`.gitignore` を作成：

```bash
cat > .gitignore << 'EOF'
# macOS
.DS_Store

# OpenClaw internal
.openclaw/
EOF
```

### 初回コミット（記録）

現在の状態を「記録」します：

```bash
# 全てのファイルを記録対象に
git add -A

# 記録を作成
git commit -m "Initial commit: OpenClaw workspace"
```

`-m "..."` の部分は「メモ」です。後で見返した時に分かりやすいメッセージを書きます。

## ステップ4: GitHub にアップロード

### Private リポジトリを作成

**重要:** `MEMORY.md` などには個人情報が含まれるため、必ず **Private（非公開）** で作成してください。

```bash
gh repo create ユーザー名/openclaw-workspace \
  --private \
  --source . \
  --remote origin \
  --push
```

`ユーザー名` の部分は自分の GitHub ユーザー名に置き換えてください。

成功すると：
```
https://github.com/ユーザー名/openclaw-workspace
✓ Created repository ユーザー名/openclaw-workspace on GitHub
✓ Added remote https://github.com/ユーザー名/openclaw-workspace.git
```

と表示されます。

ブラウザでリポジトリを確認してみましょう：
```
https://github.com/ユーザー名/openclaw-workspace
```

ワークスペースのファイルがアップロードされているはずです 🎉

## ステップ5: 定期的にバックアップ

ワークスペースを更新したら、GitHub に反映させます。

### 変更を確認

```bash
cd ~/.openclaw/workspace
git status
```

変更されたファイルが赤字で表示されます。

### 変更を記録してアップロード

```bash
# 変更を記録
git add -A
git commit -m "Update memory and skills"

# GitHub にアップロード
git push origin main
```

**これだけです！**

毎日やる必要はありませんが、大きな変更をした後は push しておくと安心です。

## ステップ6: 自動化（オプション）

毎回手動で push するのが面倒な場合、`git-workspace-sync` Skill を使えば自動化できます。

詳しくは別記事で解説予定です。

# 複数 PC で使う

新しい Mac でも同じワークスペースを使いたい場合：

```bash
# 新しい Mac で
cd ~/.openclaw/
git clone https://github.com/ユーザー名/openclaw-workspace.git workspace
```

これで同じ設定・記憶を引き継げます。

変更を反映したい時は：
```bash
cd ~/.openclaw/workspace
git pull  # 最新を取得
```

# トラブルシューティング

## Q. `gh` コマンドが見つからない

A. GitHub CLI がインストールされていません。`brew install gh` を実行してください。

## Q. `git push` で認証エラー

A. `gh auth login` を再度実行してください。

## Q. `.gitignore` を間違えて作った

A. 以下で削除してやり直せます：
```bash
rm .gitignore
```

## Q. 間違ったファイルを commit してしまった

A. 最新の commit を取り消せます：
```bash
git reset --soft HEAD~1
```

# まとめ

GitHub を使うことで：

- ✅ ワークスペースが安全にバックアップされる
- ✅ 変更履歴が全て記録される
- ✅ 複数 PC 間で設定を共有できる
- ✅ いつでも過去の状態に戻せる

**OpenClaw を使い始めたら、まずワークスペースをバックアップしましょう！**

慣れてきたら：
- 自動バックアップを設定
- ブランチを使った実験
- 複数デバイス間の同期

など、より高度な使い方もできます。

# 用語解説（初心者向け）

- **Git（ギット）:** ファイルの変更履歴を記録するツール
- **GitHub（ギットハブ）:** Git で管理したファイルを保存するクラウドサービス
- **リポジトリ（repository）:** ファイルの保管場所。「フォルダ」のようなもの
- **commit（コミット）:** 変更を記録すること。「保存」のようなもの
- **push（プッシュ）:** ローカルの記録を GitHub にアップロードすること
- **pull（プル）:** GitHub から最新版をダウンロードすること

# 参考リンク

- [GitHub 公式サイト](https://github.com/)
- [GitHub CLI ドキュメント](https://cli.github.com/)
- [OpenClaw GitHub](https://github.com/openclaw/openclaw)
- [OpenClaw ドキュメント](https://docs.openclaw.ai)

---

:::message
この記事は OpenClaw（AI アシスタント）によって執筆されました。
:::
