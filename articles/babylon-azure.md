---
title: "Babylon.jsで3DViewerをAzureに乗せる"
emoji: "🔥"
type: "tech" # tech: 技術記事 / idea: アイデア
topics: ["Azure","BabylonJS","webpack"]
published: false
---

# 概要


# 筆者の環境

|項目|version|
|---|---|
|OS|Windows10 Home|
|Node.js|v14.15.4|
|babylonjs|5.0.0-beta.11|

# Babylon.js × Webpackの準備

```powershell
$ npm init -y
$ npm install -D webpack webpack-cli webpack-dev-server babel-loader @babel/core  @babel/preset-env
```
Babylon.jsのライブラリをinstallします。
```powershell
$ npm i babylonjs@preview
$ npm i babylonjs-loaders@preview
$ npm i babylonjs-materials@preview
```

`package.json`が生成されます。便利のため、`scripts`にビルドコマンド等を追記しておきます。

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

次のようなディレクトリ構成でファイルを目指します。

```
.
├── dist/
│   └── index.html
│   └── 404.html
│   └── main.js (npm run buildにより自動生成)
├── node_modules/ (自動生成/gitignore対象)
├── src/
│   └── index.js
├── package-lock.json
├── package.json
└── webpack.config.js

```
webpack.config.jsに次のように書き込みます。
```js:webpack.config.js
module.exports = {
    // モード値を production に設定すると最適化された状態で、
    // development に設定するとソースマップ有効でJSファイルが出力される
    mode: "development",

    // ローカル開発用環境を立ち上げる
    // 実行時にブラウザが自動的に localhost を開く
    devServer: {
        contentBase: "dist",
        open: true
    },
};
```



index.htmlは次のように実装します。

```html:index.html
<!DOCTYPE html>
<html lang="ja">

<head>
    <meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
    <title>Babylon Sample</title>
</head>

<body>

    <canvas class="webgl" id="renderCanvas" touch-action="none" width="1920px" height="1080px"></canvas>
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
index.jsを次のように実装。

```javascript:index.js
import * as BABYLON from 'babylonjs';
import 'babylonjs-materials';
import 'babylonjs-loaders';

const canvas = document.getElementById("renderCanvas"); // Get the canvas element
const engine = new BABYLON.Engine(canvas, true); // Generate the BABYLON 3D engine

// Add your code here matching the playground format
const createScene = () => {
    const scene = new BABYLON.Scene(engine);
    const camera = new BABYLON.ArcRotateCamera("camera", -Math.PI / 2, Math.PI / 2.5, 3, new BABYLON.Vector3(0, 0, 0));
    camera.attachControl(canvas, true);
    BABYLON.SceneLoader.Append("assets/", "cheese.glb", scene, function (scene) {
        scene.createDefaultCameraOrLight(true, true, true);
        scene.activeCamera.alpha += Math.PI;
    });
    var hdrTexture = BABYLON.CubeTexture.CreateFromPrefilteredData("./assets/environment.dds", scene);
    var currentSkybox = scene.createDefaultSkybox(hdrTexture, true);
    return scene;
}
const scene = createScene();

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

# 3Dモデル (glbファイル)と環境ファイル(dds)の準備

今回3Dモデルの準備は、Lidar付きiPad ProによるScanアプリ「[Scaniverse - LiDAR 3D Scanner ](https://apps.apple.com/jp/app/scaniverse-lidar-3d-scanner/id1541433223)」を用いました。

アプリでScanした後に[Share]>[Export Model]>[GLB]を選択してExportします。

もし、Scanアプリを用意できない方は[Sketchfab](https://sketchfab.com/3d-models?features=downloadable&licenses=7c23a1ba438d4306920229c12afcb5f9&sort_by=-likeCount)でダウンロード可能かつ無料かつCC0ライセンスの3Dモデルをダウンロードして、Blenderなどでglb形式に変更すると良いと思います。

![](/images/babylon/2022-02-25-02-00-18.png)

Babylon.jsの環境テクスチャの設定をするためにはcube textureを含んだHDR系のファイル(dds or env形式)を準備します。

今回は、[Babylon.jsのサンプル](https://playground.babylonjs.com/#WGZLGJ)で用いているddsファイルをダウンロードして使いましょう。
[https://playground.babylonjs.com/textures/environment.dds](https://playground.babylonjs.com/textures/environment.dds)
からダウンロードできます。

次のようにglbファイルとddsファイルを置きます。

```
.
├── dist/
│   └── assets/
│       └── cheese.glb
│       └── environment.dds
│   └── index.html
│   └── 404.html
│   └── main.js (npm run buildにより自動生成)
├── node_modules/ (自動生成/gitignore対象)
├── src/
│   └── index.js
├── package-lock.json
├── package.json
└── webpack.config.js

```

## ローカルサーバーで確かめる

手段は何でもいいですが、ローカルサーバーを立ち上げます。

https://qiita.com/iwaken71/items/f9a1dcb06e404ad6469f

この記事では、VSCodeの拡張機能のLive Serverを使います。
dist/index.htmlを参照してViewerが確認できたら成功です！

![](/images/babylon/2022-02-25-02-08-54.png)

ここまで準備できたらAzure Storageにアップロードすることで、Webサイトとして反映させます。


# Azure Storageを使用する

## 前提
- Azureの無料アカウントを持っている

## 手順

- ストレージアカウントを作成
- 静的なWebサイトのホスティングを有効にする
- Visual Studio CodeからDeployする

### ストレージアカウントを作成

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

### 静的なWebサイトのホスティングを有効にする

[Azure Portal](https://portal.azure.com/#home)から先ほど作成したストレージアカウントを選択。

概要など書かれているリストから[静的なWebサイト]を選択。

![](/images/babylon/2022-02-25-00-55-11.png)

- [有効]に変更
- インデックスドキュメント名に「index.html」と入力
- エラードキュメントのパスに「404.html」と入力
- [保存]を選択

![](/images/babylon/2022-02-25-00-58-29.png)

### Visual Studio CodeからDeployする

- Azure Storage拡張機能をインストール
- distフォルダを右クリック
    - [Deploy to Static Website via Azure Storage]を選択
- [Sign in to Azure]を選択
    - Webサイト上でSign in
- Select subscription
    - Pay-As-You-Goを選択
- Select Storage Account
    - [babylonviewer]を選択

![](/images/babylon/2022-02-25-01-09-51.png)

選択するとDeployが始まる。
終了すると、デプロイ完了！

https://babylonviewer.z11.web.core.windows.net/

# 参考
https://zenn.dev/hukurouo/articles/three-js-article-1
https://doc.babylonjs.com/divingDeeper/developWithBjs/npmSupport
https://playground.babylonjs.com/#WGZLGJ
https://docs.microsoft.com/ja-jp/azure/storage/blobs/storage-blob-static-website-host
https://docs.microsoft.com/ja-jp/azure/storage/common/storage-account-create?tabs=azure-portal
https://docs.microsoft.com/ja-jp/azure/storage/blobs/storage-blob-static-website-how-to?tabs=azure-portal
https://doc.babylonjs.com/divingDeeper/materials/using/HDREnvironment