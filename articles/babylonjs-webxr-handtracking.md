---
title: "Babylon.jsでWebXR向けにHand Trackingの実装したが動かないときに見るブラウザ設定"
emoji: "🔥"
type: "tech" # tech: 技術記事 / idea: アイデア
topics: ["BabylonJS","AR","VR"]
published: false
---

# 始めに
[Babylon.js](https://www.babylonjs.com/)はブラウザ上でリアルタイムに動作する3Dレンダリングフレームワークの1つです。OSSとなりますので、誰でも無料で使用することができます。

この記事では、以下の動画やのように、Quest2とHoloLens2で起動するWebXRアプリにハンドトラキング機能を追加したときにつまずいたブラウザの設定の解決手法を共有します。

![](/images/babylon/baby_holo_hand.gif)

https://twitter.com/iwaken71/status/1529184657589555200?s=20&t=r2gkISUdKbKDzgpIHHSuDg

この記事は、[Babylon.jsでWebXR実装し、QuestとHoloLensで動かす](https://zenn.dev/iwaken71/articles/babylonjs-webxr-start)を読んだ後に読むと理解しやすいです。

また、今回のサンプル実装はGithubに公開していますので、詳しい実装を見たい方は[Github](https://github.com/iwaken71/babylon_hololens_piano) 、自分のQuest2やHoloLens2で体験したい方は[体験ページ](https://zenn.dev/iwaken71/articles/babylonjs-webxr-start)を使ってください。

また、今回のピアノのWebXRアプリは[チュートリアル: Babylon.js を使用して WebXR でピアノを構築する](https://docs.microsoft.com/ja-jp/windows/mixed-reality/develop/javascript/tutorials/babylonjs-webxr-piano/introduction-01)を参考にして実装しました。

# 起きた現象

[Docs](https://doc.babylonjs.com/divingDeeper/webXR/WebXRSelectedFeatures)に従ってHand Trackingの実装を追加したのですが、Meta Quest2のブラウザを起動しても、HoloLens2のブラウザを起動してもHand Trackingを使用できませんでした。

# 行った実装

WebXR実装の部分のうち、Hand Trackingの実装部分をご紹介します。本来であれば、この実装をすればHandTrackingとして認識し、手の部分にキューブが現れるのですが...

```js:index.js
  const xrHelper = await scene.createDefaultXRExperienceAsync();
  const featuresManager = xrHelper.baseExperience.featuresManager;
  //中略

  featuresManager.enableFeature(BABYLON.WebXRFeatureName.HAND_TRACKING, "latest", {
      xrInput: xrHelper.input,
      jointMeshes: {
          disableDefaultHandMesh: true,
          enablePhysics: true
      }
  });
```

本当はこうなってほしいが、ならない。
![](/images/babylon/baby_holo_hand.gif)

# 解決方法: ブラウザの設定


## Meta Quest2編

- Meta Quest Browserを開く
- 「chrome://flags」で検索
- 「webxr」で検索
- 「WebXR experiences with hand and joints tracking」をEnabledに変える

![](/images/babylon/2022-05-30-03-33-28.png)

## HoloLens2編

- Microsoft Edgeを開く
- 「edge://flags」で検索
- 「webxr」で検索
- 「WebXR Incubations」をEnabledに変える

![](/images/babylon/2022-05-30-03-35-12.png)

# まとめ

ブラウザの設定をすることでハンドラッキングが有効になりました！
2回目以降は設定せずともハンドトラッキングを使えるようになります。

# 参考ページ

- https://webxr-handtracking.vercel.app/
- https://speakerdeck.com/drumath2237/edge-on-hololens2deqing-lu-niwebxrsurutokigalai-ta?slide=8
- https://doc.babylonjs.com/divingDeeper/webXR/WebXRSelectedFeatures