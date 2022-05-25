---
title: "Babylon.jsでWebXR実装し、QuestとHoloLensで動かす"
emoji: "🔥"
type: "tech" # tech: 技術記事 / idea: アイデア
topics: ["BabylonJS","WebXR","VR","AR","HoloLens"]
published: true
---

# はじめに

[Babylon.js](https://www.babylonjs.com/)はブラウザ上でリアルタイムに動作する3Dレンダリングフレームワークの1つです。OSSとなりますので、誰でも無料で使用することができます。

この記事では、以下のツイートのように、Quest2とHoloLens2で起動するWebXRアプリの開発を行います。

https://twitter.com/iwaken71/status/1529157784075644929?s=20&t=OXYvQyV0GExFJEDNQyRoAA


# 参考ページ

今回の実装はGithubにアップロードしましたので、実装を参考にしたい方はこちら参考にしてください。

https://github.com/iwaken71/babylon_hololens_piano

実際のWebアプリのURLがこちら

https://iwaken71.github.io/babylon_hololens_piano/

今回参考にしたチュートリアルページがこちら

https://docs.microsoft.com/ja-jp/windows/mixed-reality/develop/javascript/tutorials/babylonjs-webxr-piano/introduction-01

公式ドキュメントはこちら

https://doc.babylonjs.com/divingDeeper/webXR/introToWebXR

# 前提

- node.js
  - v16.14.1
- Babylon.js
  - 5.7.0

# WebXRの実装箇所

今回ピアノの実装になっているのですが、今回のWebXR実装にするために大事な実装部分はこちらです。


```js:index.js
const createScene = async function () {

    //前略

    const xrHelper = await scene.createDefaultXRExperienceAsync();
    const featuresManager = xrHelper.baseExperience.featuresManager;
    featuresManager.enableFeature(BABYLON.WebXRFeatureName.POINTER_SELECTION, "stable", {
        xrInput: xrHelper.input,
        enablePointerSelectionOnAllControllers: true        
    });


    const ground = BABYLON.MeshBuilder.CreateGround("ground", {width: 400, height: 400});

    featuresManager.enableFeature(BABYLON.WebXRFeatureName.TELEPORTATION, "stable", {
        xrInput: xrHelper.input,
        floorMeshes: [ground],
        snapPositions: [new BABYLON.Vector3(2.4*3.5*scale, 0, -10*scale)],
    });

    //略

}
```

1つ1つ見ていきます。

# WebXR体験を追加

```js
    const xrHelper = await scene.createDefaultXRExperienceAsync();
```

とりあえず、この一行を書くと、WebXRの体験が可能になります。
awaitを使いたい場合、async化する必要があるため、本記事のサンプルプロジェクトではasyncで全体をくくっております。

```js:index.js
(async ()=>{
    //色々書く
    const xrHelper = await scene.createDefaultXRExperienceAsync();
    //色々書く
})()

```

awaitを使わない書き方としては、Promiseとthen構文を使用します。
非同期処理のため、なにかしら対応する必要があります。

```js
const xrPromise = scene.createDefaultXRExperienceAsync();    
return xrPromise.then((xrExperience) => {
    console.log("Done, WebXR is enabled.");
    return scene;
});
```

本書では、async/await構文を推奨とし、紹介したいと思います (ドキュメントでもasync/await構文を推奨しています)

この時点で、bundleにビルドしてWebホスティングすることで、Oculus Quest2やHoloLens2で体験することができます。

# 複数のコントローラーに対応

> イマーシブ VR コントローラーを使用してピアノを演奏している場合は、一度に 1 つのコントローラーしか使用できないことに気付いたかもしれません。 Babylon.js の WebXR 機能マネージャーを使用して、XR 空でのマルチポインター サポートを有効にしましょう。

ということで、次のような実装を追加すると、あらゆるコントローラでピアノ演奏が反応するようになります。

```js
    const xrHelper = await scene.createDefaultXRExperienceAsync();  //最初のみ,以降の例文では省略  

    const featuresManager = xrHelper.baseExperience.featuresManager;
    featuresManager.enableFeature(BABYLON.WebXRFeatureName.POINTER_SELECTION, "stable", {
        xrInput: xrHelper.input,
        enablePointerSelectionOnAllControllers: true        
    });

```

このようにWebXR体験の機能を足していくためには、

```js
featuresManager.enableFeature(BABYLON.WebXRFeatureName.~~~,
"stable"/*or latest*/,{
    xrInput: xrHelper.input,
    "プロパティ名": "値"
});
```
的な構文を書きます。

# テレポーテーションに対応

VRでよく使うテレポーテーションの実装も可能です。

```js
    const ground = BABYLON.MeshBuilder.CreateGround("ground", {width: 400, height: 400});

    featuresManager.enableFeature(BABYLON.WebXRFeatureName.TELEPORTATION, "stable", {
        xrInput: xrHelper.input,
        floorMeshes: [ground],
        snapPositions: [new BABYLON.Vector3(2.4*3.5*scale, 0, -10*scale)],
    });
```

`BABYLON.WebXRFeatureName.TELEPORTATION`というのがポイントです。

```js
floorMeshes: [ground]
```
は床のメッシュを定めます。これにより現実の床の高さと仮想空間の指定したMeshの高さを揃えることができます。

floorMeshesの設定は

```js
var xrHelper = await scene.createDefaultXRExperienceAsync({
    xrInput: xrHelper.input,
    floorMeshes: [ground] /* Array of meshes to be used as landing points */,
});

```

と言った書き方でも可能です。

snapPositionsを設定すると、テレポーテーション時に着地ポイントが目立つようになるそうです (ドキュメント要約→まだ実機確認していない)

# まとめ

Babylon.jsを使うと今までの実装に数行追加するだけでWebXRの体験を作ることができます。みなさんも触ってみて体験してみてください。


# 告知

Babylon.jsの日本コミュニティを主催しています。
Babylon.jsを学びたい人であれば誰でも参加OKですので、気軽に参加してください！

https://note.com/iwaken71/n/n0fd66c814fd2

# おすすめ資料

https://speakerdeck.com/yuhara0928/babylon-dot-js-dejian-dan-webxr