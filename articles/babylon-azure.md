---
title: "【Babylon.js×Azure Storage】LiDARスキャンした3Dオブジェクトを自作Webサイトに表示させるまで一気通貫"
emoji: "🔥"
type: "tech" # tech: 技術記事 / idea: アイデア
topics: ["Azure","BabylonJS","webpack"]
published: false
---

# 概要 

こんにちは、XRエンジニアの[イワケン](https://twitter.com/iwaken71)です。Unity歴は7年目ですが、Web上で3D表現を行うWebGL開発は苦手意識があります。もし、Web上の3D表現を最低限実装するためには

- html,css,JavaScriptの開発の知識
- WebサイトをホスティングさせるためのWebサーバーの準備
- Web3D表示のためのフレームワーク実装

が必要です。
一方で**これらを一気通貫で説明してくれるチュートリアルや解説Webページはほとんどありません。**
つまり、初学者にとっては、それぞれの開発の知識を得たうえで理解しながら組み合わせて実現しなくてはならない。これがキツイ。

なので、この記事では上記の3つが初めての方も、記事を見て手を動かしていけばとりあえず動くモノができるような記事を目指します。

# この記事を終えたあとの私のアウトプット

こちらのWebサイトが今回のアウトプットです。
https://babylonviewer.z11.web.core.windows.net/

![](/images/babylon/cheese.gif)


今回は、家にあった粉チーズをLiDARスキャンしてWeb上に3D表示しました。

# この記事で伝えたいこと

-  **Babylon.jsによるWebの3DViewer表示する最小単位実装 (一番重要)** 
    - npmとwebpackによるパッケージ管理のやり方一例
    - Azure Storageでの静的Webサイトホスティング

# 筆者の環境

|項目|version|
|---|---|
|OS|Windows10 Home|
|Node.js|v14.15.4|
|babylonjs|5.0.0-beta.11|
|webpack|5.69.1|
|webpack-cli|4.9.2|
|webpack-dev-server|4.7.4|

開発Editorは[Visual Studio Code](https://azure.microsoft.com/ja-jp/products/visual-studio-code/)を使用。今回の記事では必須です。
iPad Proスキャンアプリは[Scaniverse](https://apps.apple.com/jp/app/scaniverse-lidar-3d-scanner/id1541433223)を使用。

# 使用技術についての考察

## Babylon.js (WebGL 3Dエンジン)
Babylon.jsはオープンソースのWeb rendering enginesです。
[PlayGround](https://playground.babylonjs.com/), [Sandbox](https://sandbox.babylonjs.com/)など、GUIでのサポートサービスがあるのが個人的な推しポイントです。

近しいWebGL 3Dエンジンのフレームワークとしては

- [Babylon.js](https://github.com/BabylonJS/Babylon.js) (Microsoft開発/Github Star数16k)
- [three.js](https://github.com/mrdoob/three.js/) (定番/Github Star数79.5k)
- [Cesium](https://github.com/CesiumGS/cesium) (3D地球儀,2D地図/Github Star数8.3k)
- [Filament](https://github.com/google/filament) (Google開発/Github Star数13.6k)

などがあります。

## Azure Storage (Hostingサーバー)
Webサイトを提供するHostingサーバーの準備になります。今回は趣味用としてシンプルに実現できるCloud Storageにデプロイする方法を考えます。(セキュリティや負荷計算,API使用など考えていないので、本番のWebサイトでは使用しない方がいいと思います)

この用途では、3つの会社のクラウドサービスを選択できます。

- [Azure Blob Storage](https://azure.microsoft.com/ja-jp/services/storage/blobs/)
- [AWS S3](https://aws.amazon.com/jp/s3/)
- [GCP Cloud Storage](https://cloud.google.com/storage)

どれがいいかというのは、好みもあると思います。
今回はチャレンジも含めて[Azure Blob Storage](https://azure.microsoft.com/ja-jp/services/storage/blobs/)を使ってみようと思います。

使用感としては、チュートリアルみながらスイスイできました。
Visual Studio Codeとも連携しているので直感的に操作しやすい部分があります。

本来は金額含めて精査すべきですが、今回は述べません。

## npmとwebpack (パッケージ管理)

Babylon.jsという外部パッケージを使用したい時に、Web開発でどのようにパッケージ管理するのかという疑問に対して、様々なWeb開発者にヒアリングしたところ

- npm (Node package manager)でパッケージ管理はほぼ必須
- webpackはウェブコンテンツを構成するファイルをまとめるツールとして有用 (使っている人が多い)

という意見をいただき、[npm](https://www.npmjs.com/)と[webpack](https://webpack.js.org/)での手順をご紹介します。

## LiDARスキャンアプリ

こちらの記事を参考にして選択いただくと良いと思います。
https://note.com/iwamah1/n/n5df9a5daaae4

今回は最終的に3Dモデルを「**glb形式 or gltf形式**」にする必要があります。
なので、glb形式のExportに対応しているアプリが良いと思います。

この記事を参考にすると

- Scaniverse
- Polycam
- 3d Scanner App™

などが対応しています。
今回は気分でScaniverseを使用しました。

# 手順

- 3Dモデル(glbファイル)と環境ファイル(dds)の準備
- npmでBabylon.js × webpackの準備
- Azure Storageの準備
- Visual Studio CodeからDeployしてWebサイト公開

# 3Dモデル (glbファイル)と環境ファイル(dds)の準備

3Dモデルはすでにイメージできているかと思うのですが、今回環境ファイルの準備もフローに入れたいと思います。
環境ファイルとは、雑に言うとライティング情報を含んだ画像ファイルで、よりリアル調のレンダリングに貢献してくれるものです。

## 3Dモデル (glbファイル)の準備 
今回3Dモデルの準備は、Lidar付きiPad ProによるScanアプリ「[Scaniverse - LiDAR 3D Scanner ](https://apps.apple.com/jp/app/scaniverse-lidar-3d-scanner/id1541433223)」を用いました。

アプリでScanした後に[Share]>[Export Model]>[GLB]を選択してExportします。

もし、Scanアプリを用意できない方は[Sketchfab](https://sketchfab.com/3d-models?features=downloadable&licenses=7c23a1ba438d4306920229c12afcb5f9&sort_by=-likeCount)でダウンロード可能かつ無料かつCC0ライセンスの3Dモデルをダウンロードして、Blenderなどでglb形式に変更すると良いと思います。

![](/images/babylon/2022-02-25-02-00-18.png)

## 環境ファイル(dds)の準備

Babylon.jsの環境テクスチャの設定をするためにはcube textureを含んだHDR系のファイル(dds or env形式)を準備します。

今回は、[Babylon.jsのサンプル](https://playground.babylonjs.com/#WGZLGJ)で用いているddsファイルをダウンロードして使いましょう。
[https://playground.babylonjs.com/textures/environment.dds](https://playground.babylonjs.com/textures/environment.dds)
からダウンロードできます。

# npmでBabylon.js × webpackの準備

今回開発用のディレクトリを作ります。名前は好きな名前で良いです。

```powershell
$ mkdir AzureBabylonJS
$ cd AzureBabylonJS
```

npm環境のセットアップし、webpackモジュールをインストールします。

```powershell
$ npm init -y
$ npm install -D webpack webpack-cli webpack-dev-server babel-loader @babel/core  @babel/preset-env
```
Babylon.jsのモジュールをインストールします。今回は`@preview`とつけることで(2022年2月26日現在) `5.0.0-beta.11` をインストールしてきます。
なぜ自分が`@preview`にしたかというと、Babylon.jsが提供している[Playground](https://playground.babylonjs.com/)が`5.0.0-beta.11`であり、それに合わせたいためです。
```powershell
$ npm i babylonjs@preview
$ npm i babylonjs-loaders@preview
$ npm i babylonjs-materials@preview
```
この時点ではすでに
`package.json`が生成されます。npmコマンドを活用するために、`scripts`にビルドコマンド等を追記しておきます。

```json:package.json
{
  "name": "AzureBabylonJS",
  "version": "1.0.0",
  "description": "",
  "main": "index.js",
  "scripts": {
    "test": "echo \"Error: no test specified\" && exit 1",
    "build": "webpack",
    "dev": "webpack serve"
  },
  "keywords": [],
  "author": "",
  "license": "ISC",
  "devDependencies": {
    "@babel/core": "^7.17.5",
    "@babel/preset-env": "^7.16.11",
    "babel-loader": "^8.2.3",
    "webpack": "^5.69.1",
    "webpack-cli": "^4.9.2",
    "webpack-dev-server": "^4.7.4"
  },
  "dependencies": {
    "babylonjs": "^5.0.0-beta.11"
  },
  "private": true
}
```

ここから次のようなディレクトリ構成でファイルを目指します。

```
.
├── dist/
│   └── assets/
│       └── cheese.glb (3Dモデル)
│       └── environment.dds (環境ファイル)
│   └── index.html
│   └── 404.html
│   └── main.js (npm run buildにより自動生成)
├── node_modules/ (自動生成/gitignore対象)
├── src/
│   └── index.js
├── package-lock.json (自動生成)
├── package.json (自動生成)
└── webpack.config.js

```

追加作業としては

- srcディレクトリを作り、index.jsというファイルを新規作成する
- webpack.config.jsというファイルを新規作成する
- distディレクトリを作り、index.html,404.htmlファイルを新規作成する

です。

webpack.config.jsに次のように書き込みます。
webpack-dev-serverのバージョンがv3かv4でdevServerの書き方が変わるようです。
筆者はv4なので、以下のような書き方にしました。

```js:webpack.config.js
const path = require('path');

module.exports = {
    // モード値を production に設定すると最適化された状態で、
    // development に設定するとソースマップ有効でJSファイルが出力される
    mode: "development",

    // ローカル開発用環境を立ち上げる
    // open:ture 実行時にブラウザが自動的に localhost を開く
    // webpack-dev-serverのv4の書き方 contentBaseオプションの代わりにstatic以下に書く。
    
    devServer: {
        static: {
            directory: path.join(__dirname, "dist"),
        },
        open: true
    },
};
```

index.htmlは次のように実装します。
`<style type="text/css"></style>`は全画面表示の実装をしています。
`<canvas id="renderCanvas" touch-action="none"></canvas>`の部分が3DViewer表示部分です。

```html:index.html
<!DOCTYPE html>
<html lang="ja">

<head>
    <meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
    <title>Babylon Sample</title>
</head>
<style type="text/css">
    html,
    body {
        margin: 0;
        padding: 0;
        width: 100vw;
        height: 100vh;
    }

    #renderCanvas {
        margin: 0;
        padding: 0;
        width: 100%;
        height: 100%;
    }
</style>

<body>

    <canvas id="renderCanvas" touch-action="none"></canvas>
    <script type="text/javascript" src="main.js"></script>

</body>

</html>
```
404.htmlは今回は最低限の実装。

```html:404.html
<!DOCTYPE html>
<html>

<body>
    <h1>404</h1>
</body>

</html>
```
index.jsを次のように実装。ここが、Babylon.jsによるWebGLの実装です。

```javascript:index.js
import * as BABYLON from 'babylonjs';
import 'babylonjs-materials';
import 'babylonjs-loaders';
const canvas = document.getElementById("renderCanvas"); // Get the canvas element
const engine = new BABYLON.Engine(canvas, true); // Generate the BABYLON 3D engine

// Add your code here matching the playground format
const createScene = () => {
    const scene = new BABYLON.Scene(engine);
    var hdrTexture = BABYLON.CubeTexture.CreateFromPrefilteredData("./assets/environment.dds", scene);
    var currentSkybox = scene.createDefaultSkybox(hdrTexture, true);
    const camera = new BABYLON.ArcRotateCamera("camera", -Math.PI / 2, Math.PI / 2.5, 3, new BABYLON.Vector3(0, 0, 0));
    BABYLON.SceneLoader.Append("assets/", "cheese.glb", scene, function (scene) {
        scene.createDefaultCameraOrLight(true, true, true);
        scene.activeCamera.alpha += Math.PI;
    });
    return scene;
}
const scene = createScene(); //Call the createScene function

// Register a render loop to repeatedly render the scene
engine.runRenderLoop(function () {
    scene.render();
});

// Watch for browser/canvas resize events
window.addEventListener("resize", function () {
    engine.resize();
});
```

この状態で

```powershell
$ npm run build
```

を実行すると、distフォルダが生えてきます。
distフォルダ内に、`main.js`が生成されています。

## ローカルサーバーで確かめる

手段は何でもいいですが、ローカルサーバーを立ち上げて確かめます。

https://qiita.com/iwaken71/items/f9a1dcb06e404ad6469f

慣れていない方はVSCodeの拡張機能のLive Serverがおすすめです。
dist/index.htmlを参照してViewerが確認できたら成功です！

![](/images/babylon/2022-02-25-02-08-54.png)

ホットリロードしながら、変更したらビルド&ブラウザで確認！をしたい場合は

```powershell
npm run dev
```

を実行します。すると http://localhost:8080/ で確認することができます。こちらも非常に便利です。

先ほど`package.json`の`scripts`に`"dev": "webpack serve"`を追加したおかげで

`npm run dev` を実行すると `npx webpack serve`が実行されるようになっているおかげです。

ここまで準備できたらAzure Storageにアップロードすることで、Webサイトとして公開します。

# Azure Storageの準備

ローカルサーバーで動くのを確認できたため、外部の人がアクセスできるサーバーに置けば、全世界の人が体験できるWebサイトとして公開できるはずです。
そのための準備をしていきます。

## 前提
- Azureの無料アカウントを持っている

## 手順

- ストレージアカウントを作成
- 静的なWebサイトのホスティングを有効にする
- Visual Studio CodeからDeployする

## ストレージアカウントを作成

[Azure Portal](https://portal.azure.com/#home)にアクセス

Azureサービスから[ストレージアカウント]を選択します
![](/images/babylon/2022-02-25-00-39-21.png)

[ストレージアカウント]ページで[作成]を選択します。
![](/images/babylon/2022-02-25-00-39-58.png)

[基本]タブから、記入します。今回以下のような設定をしました。設定が終了したら[確認及び作成]を選択します。次の画面でも[作成]を選択。

|項目|記入例|
|---|---|
|サブスクリプション|Pay-As-You-Go|
|リソースグループ|3DViewer (名前は任意)|
|ストレージアカウント名|babylonviewer|
|地域|(Asia Pacific) Japan East|
|パフォーマンス|Standard|
|冗長性|geo 冗長ストレージ(GRS)|

![](/images/babylon/2022-02-25-00-43-47.png)

## 静的なWebサイトのホスティングを有効にする

[Azure Portal](https://portal.azure.com/#home)から先ほど作成したストレージアカウントを選択。

概要など書かれているリストから[静的なWebサイト]を選択。

![](/images/babylon/2022-02-25-00-55-11.png)

- [有効]に変更
- インデックスドキュメント名に「index.html」と入力
- エラードキュメントのパスに「404.html」と入力
- [保存]を選択

![](/images/babylon/2022-02-25-00-58-29.png)

## Visual Studio CodeからDeployする

- [VSCodeのAzure Storage拡張機能](https://marketplace.visualstudio.com/items?itemName=ms-azuretools.vscode-azurestorage)をインストール
- distフォルダを右クリック
    - [Deploy to Static Website via Azure Storage]を選択
- [Sign in to Azure]を選択
    - Webサイト上でSign in
- Select subscription
    - [Pay-As-You-Go]を選択
- Select Storage Account
    - [babylonviewer]を選択

![](/images/babylon/2022-02-25-01-09-51.png)

選択するとDeployが始まる。
終了すると、デプロイ完了！

https://babylonviewer.z11.web.core.windows.net/

![](/images/babylon/cheese.gif)

# 今回の留意点

今回Azureの12ヵ月無料期間を用いてAzure Blob Storageを使用しましたが、本来はCloudStorageを使用するのに少なからずお金がかかります。自分の状況がどうか調べたうえで使用お願いします。

# 参考記事
https://zenn.dev/hukurouo/articles/three-js-article-1
https://doc.babylonjs.com/divingDeeper/developWithBjs/npmSupport
https://playground.babylonjs.com/#WGZLGJ
https://docs.microsoft.com/ja-jp/azure/storage/blobs/storage-blob-static-website-host
https://docs.microsoft.com/ja-jp/azure/storage/common/storage-account-create?tabs=azure-portal
https://docs.microsoft.com/ja-jp/azure/storage/blobs/storage-blob-static-website-how-to?tabs=azure-portal
https://doc.babylonjs.com/divingDeeper/materials/using/HDREnvironment
https://qiita.com/chocomint_t/items/4bc57945bce081922582