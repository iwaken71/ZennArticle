
---
title: "Babylon.jsでMeshをダブルクリック検知を実装する"
emoji: "🔥"
type: "tech" # tech: 技術記事 / idea: アイデア
topics: ["babylonjs"]
published: false
---

# はじめに
[Babylon.js](https://www.babylonjs.com/)は**ブラウザ上でリアルタイムに動作する3Dレンダリングフレームワーク**の1つです。OSSとなりますので、誰でも無料で使用することができます。
この記事はBabylon.jsでMeshをダブルクリック検知を実装する方法を共有します。

# 提案ソースコード

全体

```js
import * as BABYLON from 'babylonjs';
import {Engine, Scene, ExecuteCodeAction, ActionManager} from 'babylonjs';
const canvas = document.getElementById("renderCanvas");
const engine = new Engine(canvas, true);
const createScene = function () {
    //ダブルクリックの検知実装
    const doubleClickAction = new ExecuteCodeAction(ActionManager.OnDoublePickTrigger, 
    () => {
        console.log("double click");
    });
    const mesh = BABYLON.MeshBuilder.CreateBox("box");
    mesh.actionManager = new ActionManager(scene);
    mesh.actionManager.registerAction(doubleClickAction);

    return scene;
}
```

ダブルクリックの検知実装

```js
const doubleClickAction = new ExecuteCodeAction(ActionManager.OnDoublePickTrigger, () => {
    console.log("double click");
});
mesh.actionManager = new ActionManager(scene);
mesh.actionManager.registerAction(doubleClickAction); //meshにActionを登録する
```

# ダブルクリック以外のイベント

`ActionManager.OnDoublePickTrigger`の部分を変更することで、ダブルクリック以外のイベントも検出できます。

https://doc.babylonjs.com/typedoc/classes/BABYLON.ActionManager

こちらから確認できます。

| 名前                | 意味 |
| ------------------- | ---- |
| OnCenterPickTrigger |      |