---
title: "Vite×Vue 3×Babylon.jsの最小限構成を作る"
emoji: "🔥"
type: "tech" # tech: 技術記事 / idea: アイデア
topics: ["babylonjs","vite","vue"]
published: true
---

# はじめに

Vue.jsとBabylon.jsのサンプルを作ろうとしたときに、Web開発に慣れていないとどう作ればいいかわからないものです。
今回は最小限の構成を作るまでの手順を紹介します。

# 環境

|項目|バージョン|
|---|---|
|Node.js|v16.14.0|
|vue|3.2.25|
|vite|2.8.6|
|babylonjs/core|5.0.0-rc.13|

# 今回のアウトプット

## Githubレポジトリ
https://github.com/iwaken71/vite-vue-babylon-sample

## 動作サンプルページ
<https://iwaken71.github.io/vite-vue-babylon-sample/index.html>
![](https://user-images.githubusercontent.com/10010842/160681620-48de6906-3734-4ae9-98e2-ede6fa57c647.gif)

# 手順

## Vite+Vue.jsのセットアップ

プロジェクトのルートディレクトリに移動して、Viteの初期化コマンドをたたきます。
```
npm init vite@latest
```

すると対話式で聞かれます。

```
√ Project name: ... vue-project-test
√ Select a framework: » vue
√ Select a variant: » vue
```

ディレクトリを移動してライブラリをインストールします。

```
cd vue-project-test
npm install
```

ここでプロジェクトのディレクトリ構造はこのようになっています。

![](/images/babylon/2022-03-30-04-07-07.png)

この状態で

```
npm run dev
```
を実行すると、開発サーバーが起動します。
<http://localhost:3000/>
を検索すると、このように表示されるはずです。

![](/images/babylon/2022-03-30-04-11-27.png)

## Babylon.jsのインストール

`@babylonjs/core@preview`をinstallします。
preview版を避けたい場合は`@babylonjs/core`にします。
本記事では、5.0.0を使用したいため`@babylonjs/core@preview`を選択します。

```
npm install @babylonjs/core@preview
```

## Vue Componentを編集

ここからBabylon.jsのsceneを表示するVue Compobnentを作ります。

まず `./src/components`以下に`BabylonScene.vue`ファイルを新規作成します。
そして以下のように書きます。

@[gist](https://gist.github.com/iwaken71/0d6b42f2aa877fe04350261b01afc825)

次に`./src`フォルダ以下に`scenes`ディレクトリを作ります。その
`./src/scenes`以下に`MyFirstScene.js`ファイルを新規作成をします。そして以下のように書きます。

@[gist](https://gist.github.com/iwaken71/fa18b81ca5208bc0c8c01e0998036bb7)

次に `.src/App.vue`を開きます。そして、`HellowWorld.vue`コンポーネントを削除して、`BabylonScene.vue`コンポーネントを追加します。以下のように書きます。

@[gist](https://gist.github.com/iwaken71/bf27c3e7a487a9ea1347c07019348030)

この状態で開発サーバーを立ち上げると、Viewerが立ち上がるはずです。

```
npm run dev
```

![](https://user-images.githubusercontent.com/10010842/160681620-48de6906-3734-4ae9-98e2-ede6fa57c647.gif)

Buildすることで`./dist`以下にbundleファイルができます。
distディレクトリ以下のファイルをWebサーバーにアップロードすると、閲覧することができます。

```
npm run build
```

# 参考資料


- [これからはじめるVue.js 3実践入門   山田 祥寛](https://www.amazon.co.jp/dp/B09RSPR453/ref=cm_sw_r_tw_dp_H0FD2GM8J1SZKAARFNM2)
- [How to use BabylonJS with Vue](https://doc.babylonjs.com/extensions/Babylon.js+ExternalLibraries/BabylonJS_and_Vue/BabylonJS_and_Vue_1)
