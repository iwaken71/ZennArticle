---
title: "Babylon.jsで背景動画と3Dモデルを合成してスクリーンショットを取る"
emoji: "🔥"
type: "tech" # tech: 技術記事 / idea: アイデア
topics: ["BabylonJS"]
published: true
---
# 始めに
[Babylon.js](https://www.babylonjs.com/)はブラウザ上でリアルタイムに動作する3Dレンダリングフレームワークの1つです。OSSとなりますので、誰でも無料で使用することができます。

![](/images/gif/screenshot.gif)

この記事はこのように、Babylon.jsを用いることで動画背景と3Dモデルの描画を合成してスクリーンショットする実装を共有します。

![](/images/babylon/gousei.png)

# 実装の課題

大変なところは

- 背景動画(2D)と3Dモデル(3D)をどう合成するか
- スクリーンショットの実装をどうするか


といったところが自明でないので、解決方法を共有します。

# 解決のアイデア

Babylon.jsのカメラを2つ用意します。

- A. 背景動画(2D)を撮るカメラ
  - ORTHOGRAPHICモードに設定し背景動画(2D)のみを描画するlayerMaskを設定
- B. 3Dモデルを撮るカメラ
  - 背景を透過して3Dモデルを描画

という方針で、実装します。

# A. 背景動画(2D)を撮るカメラ


```js
function createBGCamera(scene){
    var bgCamera = new BABYLON.FreeCamera("BGCamera",new BABYLON.Vector3(0,0,-100),scene);
    bgCamera.setTarget(new BABYLON.Vector3(0,0,0));

    //ORTHOGRAPHIC_CAMERAモードに設定
    bgCamera.mode = BABYLON.Camera.ORTHOGRAPHIC_CAMERA;

    // LayerMaskを設定
    bgCamera.layerMask = 0x20000000;
    var videoPanel = BABYLON.MeshBuilder.CreateBox("VideoPanel",{width:1920,height:1080,depth:0.01},scene);
    videoPanel.layerMask = 0x20000000;
    var videoTexture = new BABYLON.VideoTexture("vidtex","video/sea.mp4", scene);
    var videoMaterial = new BABYLON.PBRMaterial("videoMaterial", scene);
    videoMaterial.albedoTexture = videoTexture;
    videoMaterial.roughness = 1;

    // videoPanelが光の影響を受けないために
    videoMaterial.unlit = true;
    videoPanel.material = videoMaterial;
    return bgCamera;
}
```


# B. 3Dモデルを撮るカメラ

```js
function createCamera(scene){
    var cameraB = new BABYLON.ArcRotateCamera("cameraB",Math.PI/2,Math.PI/2,0.04,new BABYLON.Vector3(0, 0, 0), scene);
    cameraB.attachControl(canvas, true);//インタラクティブに操作できるようになります。
    cameraB.minZ = 0.01; //nearを0.01まで描画
    scene.clearColor = new BABYLON.Color4(1,1,1,0); //背景透過
    return cameraB;
}
```

`cameraB.minZ = 0.01;`により近くを描画できるようになります。

# 合成の実装

`scene.activeCameras.push`でカメラを追加することが後に合成絵をスクリーンショットするのに重要です。
```js
const createScene = async function () {

    var scene = new BABYLON.Scene(engine);

    var cameraA = createBGCamera(scene);
    var cameraB = createCamera(scene);

    scene.activeCameras.push(cameraA);
    scene.activeCameras.push(cameraB);
    
    // Lightの追加
    var light = new BABYLON.HemisphericLight("light", new BABYLON.Vector3(0, 1, 0), scene);

    // 3DモデルのLoad
    await BABYLON.SceneLoader.ImportMeshAsync("","https://raw.githubusercontent.com/KhronosGroup/glTF-Sample-Models/master/2.0/BoomBox/glTF-Binary/", "BoomBox.glb", scene);
    return scene;
}
```

# スクリーンショットの実装

カメラの設定を`scene.activeCamera`にします。
```js
document.querySelector("#download").addEventListener("click", ()=>{
    BABYLON.Tools.CreateScreenshot(engine,scene.activeCamera,{width:canvas.width,height:canvas.height});
});
```


# 参考記事

- Babylon.js Doc
  - [Video As A Texture](https://doc.babylonjs.com/features/featuresDeepDive/materials/using/videoTexture)
  - [Class Camera](https://doc.babylonjs.com/typedoc/classes/BABYLON.Camera#ORTHOGRAPHIC_CAMERA)
  - [Layer Masks and Multi-Cam Textures](https://doc.babylonjs.com/features/featuresDeepDive/cameras/layerMasksAndMultiCam)
  - [Render Scenes To .png Files](https://doc.babylonjs.com/features/featuresDeepDive/scene/renderToPNG)