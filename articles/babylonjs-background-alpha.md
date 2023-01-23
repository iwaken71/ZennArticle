---
title: "Babylon.jsで背景透過を行う方法。一行付け加えるだけ"
emoji: "🔥"
type: "tech" # tech: 技術記事 / idea: アイデア
topics: ["BabylonJS","JavaScript"]
published: true
publication_name: "iwakenlab_book"
---

# はじめに
[Babylon.js](https://www.babylonjs.com/)は**ブラウザ上でリアルタイムに動作する3Dレンダリングフレームワーク**の1つです。OSSとなりますので、誰でも無料で使用することができます。
この記事はBabylon.jsで背景透過を行う方法を説明します。


# 何をやりたいか

こういったhtml上にBabylon.jsで描画した3Dモデルを重ねたい。(このGoogleの検索画面は画像です)

![](/images/babylon/2022-04-15-01-25-06.png)

しかし、そのまま実装すると、上書きされてしまいます。

![](/images/babylon/2022-04-15-01-27-01.png)

理想的にはこのように透過背景にしたい。
![](/images/babylon/baby.gif)

このやり方についてご紹介します。

# 一行こう書くだけ！

```javascript
scene.clearColor = new BABYLON.Color4(0,0,0,0); //背景透過のコード
```

```javascript
const createScene = () => {
    const scene = new BABYLON.Scene(engine);
    const camera = new BABYLON.ArcRotateCamera("camera", -Math.PI / 2, Math.PI / 2.5, 3, new BABYLON.Vector3(0, 0, 0));

    BABYLON.SceneLoader.Append("assets/", "sofa.glb", scene, function (scene) {
        scene.createDefaultCameraOrLight(true, true, true);
        scene.activeCamera.alpha += Math.PI;
    });
    scene.clearColor = new BABYLON.Color4(0,0,0,0); //背景透過のコード
    return scene;
}
```

## ポイント

https://doc.babylonjs.com/divingDeeper/environment/environment_introduction

こちらのドキュメントから

背景色を変えるためには

```javascript
scene.clearColor = new BABYLON.Color3(0.5, 0.8, 0.5);
```

と書かれています。しかしこれは不透明色になります。
透明度を持たせるために `new BABYLON.Color4(0,0,0,0)`のように第4引数を0にすることで透明になるようです。

# まとめ

Babylon.jsで背景透過を行う方法についてご紹介しました。
参考になれば幸いです。

筆者[イワケン](https://twitter.com/iwaken71)はBabylon.jsの可能性について掘っていきたいと思いますのでよろしくお願いいたします。



