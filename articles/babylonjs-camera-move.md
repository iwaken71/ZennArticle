---
title: "Babylon.jsでCameraをシームレスに指定の位置に移動させる"
emoji: "🔥"
type: "tech" # tech: 技術記事 / idea: アイデア
topics: ["BabylonJS","JavaScript"]
published: true
publication_name: "iwakenlab_book"
---

# はじめに

[Babylon.js](https://www.babylonjs.com/)は**ブラウザ上でリアルタイムに動作する3Dレンダリングフレームワーク**の1つです。OSSとなりますので、誰でも無料で使用することができます。

今回の記事では、下図のように、Babylon.jsでCameraをシームレスに移動させる実装を目指します。
特にUnityでは実装方法わかるけど...という人におすすめです。
![](/images/babylon/BabylonjsCamera3.gif)


UnityのC#で書くとすると、以下のような実装を書きたい。

```csharp
public class CameraMove: MonoBehaviour {
  public Transform camera;
  Vector3 currentPosition,targetPosition;
  float smoothSpeed = 3.0f;

  void Start(){
    currentPosition = camera.position;
    targetPosition = camera.position;
  }

  void Update(){
    if(Input.GetKeyDown("a")){
      targetPosition = new Vector3(0, 0, 0.05);
    }else if(Input.GetKeyDown("d")){
      targetPosition = new Vector3(0.05, 0, 0.15));
    }
  }

  void LateUpdate(){
    if(Vector3.Distance(currentPosition,targetPosition)<= 0.00001){
      currentPosition = targetPosition;
    }else{
      currentPosition = Vector3.Lerp(currentPosition,targetPosition,Time.deltaTime*smoothSpeed);
      camera.potision = currentPosition;
    }
  }
}
```

でも、Babylon.jsでどうやって書けば...ということで、書き方を整理していきたいと思います。
悩みポイントとしては

- 基本シーンの準備の仕方
- Update関数の準備の仕方
- キー入力の準備の仕方
- カメラ移動の実装の仕方

を見ていきたいと思います。

# PlayGroundで準備

https://playground.babylonjs.com/

にアクセスするとWeb上でコーディングしてリアルタイムに反応されるツールを使うことができます。

![](/images/babylon/2022-04-12-18-27-36.png)

# 基本シーンの準備の仕方

`createScene`の中に

- camera
- light
- オブジェクト

を実装していきます。

```javascript
var createScene = function () {
    const scene = new BABYLON.Scene(engine);
    camera = new BABYLON.UniversalCamera("camera", new BABYLON.Vector3(0, 0, 0.05));
    camera.minZ = 0.0001;
    camera.rotation.y = Math.PI;
    const light = new BABYLON.HemisphericLight("light",new BABYLON.Vector3(0, 1, 0),scene);
    BABYLON.SceneLoader.Append("https://raw.githubusercontent.com/BabylonJS/MeshesLibrary/master/", "boombox.glb", scene, function (scene) {
        scene.createDefaultEnvironment();
    });
    return scene;
};
```

https://playground.babylonjs.com/#SXXQ4M
![](/images/babylon/2022-04-12-20-03-44.png)

## 解説
Cameraの生成は

```javascript
// "camera"という名前で new BABYLON.Vector3(0, 0, 0.05)に生成する
let camera = new BABYLON.UniversalCamera("camera", new BABYLON.Vector3(0, 0, 0.05));
```
で行います。
他にも
- `new BABYLON.FreeCamera()`

などでも可能です。
さらに、オブジェクトを描画できるように、以下のようなコードをつけ足します。

```javascript
camera.minZ = 0.0001; // near clip
camera.rotation.y = Math.PI;
```

`camera.minZ`はNear planeといわれる値で、カメラの近くの範囲を描画する範囲になります。
デフォルトだと`1`になっているので、近くのオブジェクトがほとんど描画されません。
なので
`camera.minZ = 0.0001;`とすることで、近くのオブジェクトも描画してくれます。

`camera.rotation.y = Math.PI;`はrotationのyの値に180度を入力する実装です。単位がラジアンになるので、Math.PIとなっています。これはオブジェクトの向きやカメラの位置によって適宜入力します。

lightの生成は

```javascript
 const light = new BABYLON.HemisphericLight("light",new BABYLON.Vector3(0, 1, 0),scene);
```
オブジェクトの追加は

```javascript
BABYLON.SceneLoader.Append("https://raw.githubusercontent.com/BabylonJS/MeshesLibrary/master/", "boombox.glb", scene, function (scene) {
    scene.createDefaultEnvironment(); //省略可能
});
```

という実装をしています。
Babylon.jsのPlayGroundでは、Githubのpublicレポジトリの上のアセットにアクセスすることができます。やり方としては

`https://github.com/BabylonJS/MeshesLibrary/blob/master/boombox.glb`の3Dアセットにアクセスしたい場合は、

- `github.com`を`raw.githubusercontent.com`に置き換える
- `blob`を削除する

ことによって
`https://raw.githubusercontent.com/BabylonJS/MeshesLibrary/master/boombox.glb`というURLでglbデータを取得することができます。

sceneに追加する関数
`BABYLON.SceneLoader.Append("rootURL","sceneFileName",scene)`のように使います。

`scene.createDefaultEnvironment();`は環境マップをとりあえず追加したいときに使用します。

# Update関数の準備の仕方

Update関数とは、Unityでいうと描画のframeごとに呼ばれる関数です。
Babylon.jsでは

```javascript
scene.registerBeforeRender(function () {
    update(scene);
});
```
とすると、Render前のイベントを取得できます。
全体では次のような実装をしてみました。

```javascript
var createScene = function () {
    const scene = new BABYLON.Scene(engine);
    camera = new BABYLON.UniversalCamera("camera", new BABYLON.Vector3(0, 0, 0.05));
    camera.minZ = 0.0001;
    camera.rotation.y = Math.PI;
    const light = new BABYLON.HemisphericLight("light",new BABYLON.Vector3(0, 1, 0),scene);
    BABYLON.SceneLoader.Append("https://raw.githubusercontent.com/BabylonJS/MeshesLibrary/master/", "boombox.glb", scene, function (scene) {
        scene.createDefaultEnvironment();
    });
    scene.registerBeforeRender(function () {
        update(scene);
    });
    return scene;
};

function update(scene){
    const deltaTime = engine.getDeltaTime() / 1000;
    console.log(deltaTime);
}
```
https://playground.babylonjs.com/#SXXQ4M#4

`deltaTime (前frameから現frameまでの秒数)`を取得するためには
`engine.getDeltaTime() / 1000;`と実装します。

# キー入力の準備の仕方

https://doc.babylonjs.com/divingDeeper/scene/interactWithScenes

を参考に次のように実装しました。

```javascript
var createScene = function () {
  //中略
  scene.onKeyboardObservable.add((kbInfo) => {
    switch (kbInfo.type) {
      case BABYLON.KeyboardEventTypes.KEYDOWN:
        switch (kbInfo.event.key) {
          case "a":
          case "A":
            console.log("KeyDown:A");
            break
          case "d":
          case "D":
            console.log("KeyDown:D");
            break
        }
      break;
    }
  });
  return scene;
}
```

# カメラ移動の実装の仕方
冒頭のUnityの実装を参考にしたのように実装しました。

```javascript
let camera;
let targetPosition,currentPosition;
let smoothSpeed = 3.0

var createScene = function () {
    const scene = new BABYLON.Scene(engine);
    camera = new BABYLON.UniversalCamera("camera", new BABYLON.Vector3(0, 0, 0.05));
    camera.minZ = 0.0001;
    camera.rotation.y = Math.PI;
    //初期値を設定
    currentPosition = camera.position;
    targetPosition = camera.position;
    const light = new BABYLON.HemisphericLight("light",new BABYLON.Vector3(0, 1, 0),scene);
    BABYLON.SceneLoader.Append("https://raw.githubusercontent.com/BabylonJS/MeshesLibrary/master/", "boombox.glb", scene, function (scene) {
        scene.createDefaultEnvironment();
    });
    scene.registerBeforeRender(function () {
        update(scene);
    });

    scene.onKeyboardObservable.add((kbInfo) => {
      switch (kbInfo.type) {
        case BABYLON.KeyboardEventTypes.KEYDOWN:
          switch (kbInfo.event.key) {
            case "a":
            case "A":
              // targetPositionを設定
                targetPosition = new BABYLON.Vector3(0, 0, 0.05);
            break
            case "d":
            case "D":
                targetPosition = new BABYLON.Vector3(0.05, 0, 0.15);
            break
          }
        break;
      }
	});

    return scene;
};

function update(scene){
    const deltaTime = engine.getDeltaTime() / 1000;
    //距離がほぼゼロの時
    if(BABYLON.Vector3.DistanceSquared(currentPosition,targetPosition) <= 0.00000001){
        currentPosition = targetPosition;
        camera.position = currentPosition;
    }else{
        currentPosition = BABYLON.Vector3.Lerp(currentPosition,targetPosition,deltaTime*smoothSpeed);
        camera.position = currentPosition;
    }
}
```

https://playground.babylonjs.com/#SXXQ4M#5

![](/images/babylon/BabylonjsCamera3.gif)

# まとめ

Babylon.jsでCameraをシームレスに指定の位置に移動させる実装をしました。
参考になれば幸いです。

筆者[イワケン](https://twitter.com/iwaken71)はBabylon.jsの可能性について掘っていきたいと思いますのでよろしくお願いいたします。

# 参考ページ
https://doc.babylonjs.com/typedoc/classes/babylon.sceneloader#append
https://doc.babylonjs.com/divingDeeper/scene/interactWithScenes