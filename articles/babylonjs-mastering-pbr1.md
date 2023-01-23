---
title: "Babylon.jsのPBRMaterial紹介と簡易版Materialからの変換【ドキュメント和訳+α】"
emoji: "🔥"
type: "tech" # tech: 技術記事 / idea: アイデア
topics: ["BabylonJS","PBR","JavaScript"]
published: true
publication_name: "iwakenlab_book"
---

# はじめに

[Babylon.js](https://www.babylonjs.com/)は**ブラウザ上でリアルタイムに動作する3Dレンダリングフレームワーク**の1つです。OSSとなりますので、誰でも無料で使用することができます。
この記事は[Mastering PBR Materials](https://doc.babylonjs.com/divingDeeper/materials/using/masterPBR)を参考に、Babylon.jsにおけるPBR Materialをマスターしようという記事になります。そのその前半部分の説明になります。

# 概要

https://zenn.dev/iwaken71/articles/babylonjs-pbr

の記事紹介したように

PBR Materialの簡易版である

- PBRMetallicRoughnessMaterial
- PBRSpecularGlossinessMaterial

は、PBRの入門用としては最適ですが、詳細の制御はできません。
PBRMaterial自体を活用することで、詳細の制御をできるようになります。

以下の機能を使います。

- 屈折率 (Refraction)
- 標準的な光の減衰(Standard Light Falloff)
- ライトマップ(LightMap)
- 専用画像処理(Dedicated image processing)

例えば、PBRMaterialを活用することによって、このようなDemo Sceneを作ることができます。
https://www.babylonjs.com/demos/pbrrough/

この記事では、PBRMaterial本体と簡易バージョンとの違いについて説明します。

# MetallicRoughnessからPBRMaterialへ

PBRMaterialを、Metallic/Roughnessモードで設定するためには、以下のプロパティの少なくとも1つを設定する必要があります。

- metallic
- roughness
- metallicTexture

PBRMetallicRoughnessMaterialから大きなPBRMaterialに切り替えるためには、いくつかのプロパティの名前を変更する必要があります。

|PBRMetallicRoughnessMaterial|PBRMaterial|
|---|---|
|baseColor|albedoColor|
|baseTexture|albedoTexture|
|metallicRoughnessTexture|metallicTexture|
|environmentTexture|reflectionTexture|
|normalTexture|bumpTexture|
|occlusionTexture|ambientTexture|
|occlusionTextureStrength|ambientTextureStrength|


また、metallicやroughnessに使用するチャンネルをカスタマイズするために、シンプルなマテリアルにセットアップするためには以下のflagを設定する必要があります。
```js
pbr.useRoughnessFromMetallicTextureAlpha = false;
pbr.useRoughnessFromMetallicTextureGreen = true;
pbr.useMetallnessFromMetallicTextureBlue = true;
```

このようにMetallic SurfacesをPBRでカスタマイズしたコードサンプルが[こちら](https://playground.babylonjs.com/#2FDQT5#1478)です。

![](/images/babylon/2022-04-05-17-14-52.png)

ここまでがMetallicRoughnessからPBRMaterialへ変換するための知識でした。ここからは、利用可能なカスタムオプションを見てみましょう。

|プロパティ名|説明|
|---|---|
|**useRoughnessFromMetallicTextureAlpha**|メタリックテクスチャのアルファチャンネルにラフネス情報を含むことができる|
|**useMetallnessFromMetallicTextureBlue**|メタリックテクスチャのBlueチャンネルにメタリック情報を含むことができる (デフォルトではRedチャンネル)|
|**useAmbientOcclusionFromMetallicTextureRed**|メタリックテクスチャのRedチャンネルにアンビエントオクルージョン情報を含むことができる|
|**useAmbientInGrayScale**|ambient textureもしくはmetallic textureのRedチャンネルから、ambient occlusionを読み取るように強制できます|

# SpecularGlossinessからPBRMaterialへ

Specular/GlossinessモードでのPBRMaterialの設定は先程とは違う設定が必要です。
以下のプロパティはNULL or undefinedにする必要があります。

- metallic
- roughness
- metallicTexture

PBRSpecularGlossinessMaterialから立地なPBRMaterialに切り変えるためには、いくつかプロパティの名前も変更する必要があります。

|PBRSpecularGlossinessMaterial|PBRMaterial|
|---|---|
|diffuseColor|albedoColor|
|diffuseTexture|albedoTexture|
|specularGlossinessTexture|reflectivityTexture|
|specularColor|reflectivityColor|
|glossiness|microSurface|
|normalTexture|bumpTexture|
|occlusionTexture|ambientTexture|
|occlusionTextureStrength|ambientTextureStrength|

glossinessに使用するチャンネルをカスタマイズするために、シンプルなMaterialに設定するためには、以下のフラグを追加する必要があります。
```js
pbr.useMicroSurfaceFromReflectivityMapAlpha = false;
```

サンプルコードは[こちら](https://playground.babylonjs.com/#Z1VL3V#8)
![](/images/babylon/2022-04-05-18-58-16.png)

変換が完了したら、利用可能なカスタムオプションを見ていきます。

|プロパティ名|説明|
|---|---|
|**microSurfaceTexture**|separate textureのRチャンネルにglossinessの値を保存することができます|
|**useAlphaFromAlbedoTexture**|opacity情報をalbedo textureのアルファチャンネルに含むことができます|
|**useMicroSurfaceFromReflectivityMapAlpha**|the microSurfaceまたはglossinessの情報をreflectivity textureのアルファチャンネルに含むことができます|
|**useAmbientInGrayScale**|ambient textureもしくはmetallic textureのRedチャンネルから、ambient occlusionを読み取るように強制できます|

# 最後に

ここまでが、シンプルなMaterialからPBRMaterialの変換の話でした。

ドキュメントの続きでは、各項目の設定事項などをご紹介しています。こちらについては別記事で紹介予定です。

