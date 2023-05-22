---
title: "Babylon.jsでカメラのdepth画像をexportする"
emoji: "🔥"
type: "tech" # tech: 技術記事 / idea: アイデア
topics: ["BabylonJS","JavaScript"]
published: false
---

こんにちは！XRエンジニアのイワケンです。

今回は、Babylon.jsでカメラのdepth画像をexportする方法について説明します。

# はじめに

[Babylon.js](https://www.babylonjs.com/)は**ブラウザ上でリアルタイムに動作する3Dレンダリングフレームワーク**の1つです。OSSとなりますので、誰でも無料で使用することができます。

今回の記事では、Babylon.jsでカメラのdepth画像をexportする方法について説明します。

# 概要

Babylon.jsでカメラのdepth画像をexportする方法は、以下の2つの方法があります。

- レンダリング結果を取得する方法
- シェーダーを使う方法

## レンダリング結果を取得する方法

レンダリング結果を取得する方法は、以下のように、カメラのrenderTargetTextureを設定することで、レンダリング結果を取得することができます。

```javascript
const createScene = () => {
    const scene = new BABYLON.Scene(engine);
    const camera = new BABYLON.ArcRotateCamera("camera", -Math.PI / 2, Math.PI / 2.5, 3, new BABYLON.Vector3(0, 0, 0));
    const renderTexture = new BABYLON.RenderTargetTexture("renderTexture", 1024, scene, true);
    camera.outputRenderTarget = renderTexture;
    BABYLON.SceneLoader.Append("assets/", "sofa.glb", scene, function (scene) {
        scene.createDefaultCameraOrLight(true, true, true);
        scene.activeCamera.alpha += Math.PI;
    });

    const renderer = scene.enableDepthRenderer();
    const mat = new BABYLON.StandardMaterial("mat01", scene);
    var depthTexture = renderer.getDepthMap();

    //Sキーを押したら、depthTextureのpngでダウンロードする
    window.addEventListener("keydown", function (e) {
        if (e.key === "s") {
            BABYLON.Tools.CreateScreenshotUsingRenderTarget(engine, camera, {width:1024,height:1024}, (data) => {
                BABYLON.Tools.Download(data, "depthTexture.png");
            });
        }
    });


    return scene;
}
```






