---
title: "Babylon.jsにおけるPhysically Based Rendering(PBR)の扱い方【ドキュメント和訳】"
emoji: "🔥"
type: "tech" # tech: 技術記事 / idea: アイデア
topics: ["BabylonJS","PBR"]
published: false
---

# はじめに
この記事は[Introduction to Physically Based Rendering](https://doc.babylonjs.com/divingDeeper/materials/using/HDREnvironment)を参考にし、Babylon.jsにおけるPBRの扱い方をご紹介します。

この記事では

- 環境マップのScript上での扱い方
- 環境マップの生成/変換の仕方

の順番で紹介します。

# Physically Based Rendering(PBR)の目標

Physically Based Rendering(PBR)の目標は、現実のLightingをシミュレーションすることです。

PBRは技法の総称であり、特定の技法を選択することを強制するものではありません。
例えば、以下のようなものをあげることができます。

- [Disney](https://blog.selfshadow.com/publications/s2012-shading-course/burley/s2012_pbs_disney_brdf_slides_v2.pdf)
- [Ashkimin Shirley BRDF](http://citeseerx.ist.psu.edu/viewdoc/download?doi=10.1.1.18.4558&rep=rep1&type=pdf)

Babylon.jsのPBRはPBRMaterialのおかげで実現されています。
このマテリアルには、モダンなPBRに必要な機能がすべて含まれています。この記事では、PBRをするに始めることができる、2つのプリセットされた簡易版を見ていきます。

PBRMaterialを使用したデモはBabylon.jsのWebサイトからみることができます。

https://www.babylonjs.com/demos/pbrglossy/

![](/images/babylon/2022-04-04-20-15-23.png)

次の2つのMaterialが準備されています。

- PBRMetallicRoughnessMaterial
- PBRSpecularGlossinessMaterial

どちらもGLTFの仕様に基づいた実装をしています。

- [Metallic roughness convention](https://github.com/KhronosGroup/glTF/blob/main/specification/2.0/README.md#metallic-roughness-material) (こちらがおすすめ)
- [Specular glossiness convention](https://github.com/KhronosGroup/glTF/blob/main/extensions/2.0/Khronos/KHR_materials_pbrSpecularGlossiness/README.md) (リンク切れを起こしているので後日調査)

# PBRMetallicRoughnessMaterial

このMaterialは5つの値に基づいています

- baseColor/baseTexture
- matallic
- roughness
- metallicRoughnessTexture
- environmentTexture

## baseColor/baseTexture

baseColorはmetalnessの値によって2つの異なる解釈があります。

- materialが **metal(金属)** の場合
  - baseColorは垂直入射(F0)で測定された特定の反射率の値です。
- materialが **non-metal(非金属)** の場合
  - baseColorは素材を反射した拡散色を示します。

## metallic

materialのmetallicのスカラー値を指定します。また、metallic textureの値をスケーリングするために使用することもできます。

## roughness
materialのroughnessのスカラー値を指定します。metal Textureのroughness値をスケーリングするために使用することもできます。

## metallicRoughnessTexture

2つの値を含むTextureによって良い精度を保つことができます。RGBの
- Bチャンネルのmetallic値
- Gチャンネルのroughness値
また、Ambient occlusion をチャンネルRに保存することができます。

## environmentTexture

環境テクスチャを表す。

# Babylon Standard Materialとの違いと簡単なセットアップの仕方

インスタンス生成

```js
var pbr = new BABYLON.PBRMetallicRoughnessMaterial("pbr", scene);
```

materialを適用する
```js
sphere.material = pbr;
```

値を設定
```js
pbr.baseColor = new BABYLON.Color3(1.0, 0.766, 0.336);
pbr.metallic = 0;
pbr.roughness = 1.0;
```

こちらがコードサンプル

https://playground.babylonjs.com/#2FDQT5






