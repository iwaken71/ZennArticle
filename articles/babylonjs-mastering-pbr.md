---
title: "Babylon.jsのPBRをマスターする【ドキュメント和訳+α】"
emoji: "🔥"
type: "tech" # tech: 技術記事 / idea: アイデア
topics: ["BabylonJS","PBR","JavaScript"]
published: false
---

# はじめに

この記事は[Mastering PBR Materials](https://doc.babylonjs.com/divingDeeper/materials/using/masterPBR)を参考に、Babylon.jsにおけるPBR Materialをマスターしようという記事になります。

# 概要

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


また、光沢に使用するチャンネルをカスタマイズするために、シンプルなマテリアルにセットアップするためには以下のflagを設定する必要があります。
```js
pbr.useRoughnessFromMetallicTextureAlpha = false;
pbr.useRoughnessFromMetallicTextureGreen = true;
pbr.useMetallnessFromMetallicTextureBlue = true;
```

