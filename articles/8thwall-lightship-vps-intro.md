---
title: "8thWallのLightship VPS for Webを静岡で試してみた"
emoji: "🔥"
type: "tech" # tech: 技術記事 / idea: アイデア
topics: ["WebAR","VPS","AR"]
published: true
publication_name: "iwakenlab_book"
---

こんにちは、XRエンジニアのイワケンです。

2022年の9月22日に8th Wall Blogにて、[Introducing Lightship VPS for Web](https://www.8thwall.com/blog/post/85704231306/introducing-lightship-vps-for-web)という記事が公開されました。ついに「Web」の「VPS」が民主化されるぞ！というところで個人的には非常にワクワクしたリリースでした。

AR体験として有用な、カメラ撮影から自分の場所や向きを推定するVPS (Visual Positioning System)という技術は近年

- Spatial Anchors
- Immersal
- Pretia
- GeoSpatial API

など、様々な開発SDKが登場していましたが、すべてネイティブのスマホアプリ (iOS,Android)への対応でした。

詳しくはこちらの記事をご覧ください。
https://speakerdeck.com/satoshirobatofujimoto/vpsmatometemita

ARアプリはWebARと比べて、リッチな表現ができる一方で、手軽さではWebに劣っていることが多いです。
特に、外出先でスマホを開くときに気軽に体験できるWebARでのVPSは非常に魅力的です。

というところで、WebARで有名な8thWall社を、ポケモンGOのNiantic社が買収したことで、WebARでのVPSが早速実現できたというストーリーなのです。

この記事では、公開されたブログや[ドキュメント](https://www.8thwall.com/docs/web/#lightship-vps)をもとに、8thWallのLightship VPS for Web (以下Lightship VPS)で何ができるのか紹介しつつ、実際触ってみた手順についてご紹介します。開発合宿先の静岡で実践しました。日本最速かもしれません (一緒に旅行した中村君も同じ日に行いました)

https://twitter.com/tsukuba22_mr1/status/1573549108425818113?s=20&t=Qx4s4dQIhuQcqObfkLESnQ

## 注意

速度重視に記事を書いたので、荒削りだったり、あとで書く予定のところもあります。

# すでにあるWayspotを活用する

WayspotsはNiantic社が定義した言葉です。
簡単に言うとVPSができるスポット (ポケスポット的な) です。ただ、GPSだけでなくカメラ映像から自分の位置を推定することができます。

![](/images/babylon/2022-09-25-03-17-57.png)

私の旅行先の静岡県もいくつかWayspotsがあるようです。
この画面を開くためには、8thWallのCloud Editorから、左メニューの**Geospatial Browser**をクリックします。この単語もVPSの扱いでよく使うので覚えましょう。

Wayspotsの1つを選択すると、スキャンしたあとのようなMeshが現れます。すでに存在しているWayspotsはこのように表示されます。

![](/images/babylon/2022-09-25-03-20-57.png)

実際にデモアプリを起動して、熱海駅のSLに行ってみるとSL広場がレコメンドされます。

https://twitter.com/iwaken71/status/1573508380450205696?s=20&t=6ZXHVRoB_agIBLrZt09hXA

使用したサンプルアプリはこちら

https://8thwall.8thwall.app/vps-bespoke/

# すでにあるWayspotsに反応するWebARアプリを作る

8thWallは公開されたプロジェクトをCloneして自分のプロジェクトにすることができます。
試しにvps-bespokeのプロジェクトをCloneしましょう。

https://www.8thwall.com/8thwall/vps-bespoke

ここからClone Projectです。

続いての手順はこちらです

- 追加したいWayspotsを選択
- 「Add to Project」
- 「Project Wayspots」リストに追加されたのを確認

## 追加したいWayspotsを選択

![](/images/babylon/2022-09-25-03-32-26.png)

## 「Add to Project」
![](/images/babylon/2022-09-25-03-33-13.png)

## 「Project Wayspots」リストに追加されたのを確認
![](/images/babylon/2022-09-25-03-35-38.png)


ではソースコードをいじっていきます。

- glbデータのimport
- body.htmlの編集

## glbデータのimport

先程にexportするアイコンがあるので押します。

![](/images/babylon/2022-09-25-03-42-28.png)

glbデータをドラッグ&ドロップします。すると追加できるぞ！

![](/images/babylon/2022-09-25-03-37-40.png)

## body.htmlの編集

body.htmlを開き、vpsに関わる実装を真似しながら追加していきます。
aframe頑張っていきましょう。

```html:body.html
<a-scene
  landing-page
  vps-coaching-overlay
  background="color: #303030"
  renderer="colorManagement: true"
  gltf-model="dracoDecoderPath: https://cdn.8thwall.com/web/aframe/draco-decoder/"
  xrextras-runtime-error
  xrextras-loading
  xrweb="enableVps: true">

  <a-assets>
    <a-asset-item id="vps-mesh" src="./assets/cal-park-wayspot.glb"></a-asset-item>
    <!--追加-->
    <a-asset-item id="vps-mesh2" src="./assets/sl_1.glb"></a-asset-item>
    <!--追加-->
    <a-asset-item id="squaloons-mesh" src="./assets/squaloons.glb"></a-asset-item>
  </a-assets>
  
  <a-camera
    position="0 1.8 4"
    raycaster="objects: .cantap"
    cursor="fuse: false; rayOrigin: mouse;">
  </a-camera>

  <a-entity named-wayspot="name: california-p">
    <a-entity
      gltf-model="#vps-mesh"
      xrextras-hider-material>
    </a-entity>
    <a-entity 
      gltf-model="#squaloons-mesh"
      cubemap-realtime
      animation-mixer="clip: *">
    </a-entity>
  </a-entity>

  <!--追加-->
  <a-entity named-wayspot="name: 熱海軽便鉄道のsl">
    <a-entity
      gltf-model="#vps-mesh2"
      xrextras-hider-material>
    </a-entity>
    <a-entity 
      gltf-model="#squaloons-mesh"
      cubemap-realtime
      animation-mixer="clip: *">
    </a-entity>
  </a-entity>
  <!--追加-->

  <a-light type="directional" intensity="0.5" position="1 1 1"></a-light>
  <a-light type="ambient" intensity="1"></a-light>
</a-scene>
```

`<a-entity named-wayspot="name: 熱海軽便鉄道のsl">`のnameはGeoSpatial Browserのここを参考にしました。

![](/images/babylon/2022-09-25-03-43-59.png)


## これで実際にWayspotsに行ってみると...?

デモ動画ができ次第共有しますね。


# Wayspotがなければ作る

Wayspotsがなければ作ればいいじゃないか！ということで「ユーザー」が作ることができるみたいです。GoogleさんのARCore Geospatial APIだと、Googleストリートビューの人に期待するしかないですよね。

この記事では、ドキュメントの説明をしつつ、途中までチャレンジしたことを共有します。
手順はこちら

- Geospatial Browserにて
  - 新しいWayspotsを地図上で選択
  - Wayspotsの情報を追加
- Niantic Wayfarer Appにて
  - 対象スポットをスキャン
    - 時間帯も10回以上スキャンデータを送る

## 新しいWayspotsを地図上で選択

Create Wayspotをクリック

![](/images/babylon/2022-09-25-03-57-57.png)

![](/images/babylon/2022-09-25-03-59-38.png)

Wayspotsの情報を追加してください。名前などがもとめられます。

## Niantic Wayfarer Appの準備

Niantic Wayfarer AppはVPSのための3DMapをスキャンするためのアプリです。これを使うためにはTest Flightアプリ (iPhone8以降、iOS12以降)をインストールする必要があります。

こちらのリンクから入りましょう。

https://testflight.apple.com/join/VXu1F2jf

## 対象スポットをスキャン

アプリを立ち上げるとスキャンを直感的にすることができます。
スキャンができたら、送信します。

https://twitter.com/iwaken71/status/1573752517137088514?s=20&t=6ZXHVRoB_agIBLrZt09hXA

## 時間帯も10回以上送らないと次のステータスに進めない

結論、時間帯変えつつ、10回以上スキャン&送信をしないとWayspotsとしてActivateされないみたいです。かつ精度もいい感じである必要があります。

今回、まだ1回しかスキャンをアップロードしていないため、ステータスが進んでいません。
![](/images/babylon/2022-09-25-03-56-39.png)


# 今後

- 既存Wayspotsへの体験を実装できたか試す
- 新しいWayspotsを作るまでスキャンのアップロードを行う

# 参考

- https://www.8thwall.com/docs/web/#lightship-vps
- https://zenn.dev/iwaken71/scraps/d789840fe9af87















