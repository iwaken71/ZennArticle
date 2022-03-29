---
title: "デプロイしたZennの記事をGithubから「直接」編集・更新する"
emoji: "🔥"
type: "tech" # tech: 技術記事 / idea: アイデア
topics: ["Zenn","Github","VSCode"]
published: true
---

# はじめに

Github連携しているZennの記事を「Githubにデプロイした後ちょっとした編集をしたい」といった時に、ローカルのファイルをブランチ切ってプッシュしてプルリク送るのは面倒です。

そこで、Github上で「直接」編集して更新する方法を共有します。

## 今回試すこと

https://zenn.dev/iwaken71/articles/vite-vue-babylonjs-sample

![](/images/babylon/2022-03-30-05-20-38.png)

こちらの見出しを

```
# 背景
```
から
```
#はじめに
```
に変更してみます。

# 手順

- ZennからGithubを開く
- GithubからVisual Studio Codeを開く
- Web上で変更する
- 変更コミットする

## ZennからGithubを開く

記事にGithubで開く、というボタンを押します。

![](/images/babylon/2022-03-30-05-22-37.png)

Githubが開きます。

![](/images/babylon/2022-03-30-05-23-22.png)

ここからがポイントです。

## GithubからVisual Studio Codeを開く

Githubの画面で **ピリオドキー「.」** を押します。するとVisual Studio Codeが起動します。

![](/images/babylon/2022-03-30-05-24-35.png)

## Web上で変更する

書き換えたいところを書き換えます。
![](/images/babylon/2022-03-30-05-27-23.png)

## 変更コミットする
- Gitアイコンのタブを選択します
- 「+」ボタンを押すことでStage Changeします
![](/images/babylon/2022-03-30-05-28-13.png)


MessageにCommit Messageを書きます。書いたらエンターを押します。

![](/images/babylon/2022-03-30-05-29-47.png)

これで完了です！
Zennの記事を開くと変更されています。

![](/images/babylon/2022-03-30-05-31-16.png)

# Github上でブランチを切ってプルリクを送りたい場合
設定ボタンから[Branch]>[Create New Branch]を選択してブランチ名を書き込み選択する。
![](/images/babylon/2022-03-30-05-34-32.png)

変更箇所をコミットしたのちに「プルリクマーク」をクリック

![](/images/babylon/2022-03-30-05-40-59.png)

おなじみのプルリクの文言を記入。[Create]を選択。

![](/images/babylon/2022-03-30-05-42-32.png)

Okであれば[Merge Pull Request]を選択。[Create Merge Commit]を選択。
![](/images/babylon/2022-03-30-05-43-25.png)