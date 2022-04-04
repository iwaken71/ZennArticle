---
title: "Babylon.jsにおけるPhysically Based Rendering(PBR)の扱い方【ドキュメント和訳+α】"
emoji: "🔥"
type: "tech" # tech: 技術記事 / idea: アイデア
topics: ["BabylonJS","PBR"]
published: false
---

# はじめに
この記事は[Introduction to Physically Based Rendering](https://doc.babylonjs.com/divingDeeper/materials/using/HDREnvironment)を参考にし、Babylon.jsにおけるPBRの扱い方をご紹介します。

この記事では

- Physically Based Rendering(PBR)の目標
- PBRMetallicRoughnessMaterial
- PBRSpecularGlossinessMaterial
- Lightの設定

の順番で紹介します。

# Physically Based Rendering(PBR)の目標

Physically Based Rendering(PBR)の目標は、現実のLightingをシミュレーションすることです。

PBRは技法の総称であり、特定の技法を選択することを強制するものではありません。
例えば、以下のようなものをあげることができます。

- [Disney](https://blog.selfshadow.com/publications/s2012-shading-course/burley/s2012_pbs_disney_brdf_slides_v2.pdf)
- [Ashkimin Shirley BRDF](http://citeseerx.ist.psu.edu/viewdoc/download?doi=10.1.1.18./images/babylon/558&rep=rep1&type=pdf)

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

## Babylon Standard Materialとの違いと簡単なセットアップの仕方

インスタンス生成

```js
var pbr = new BABYLON.PBRMetallicRoughnessMaterial("pbr", scene);
```

materialを適用する
```js
sphere.material = pbr;
```

次の設定は反射が全くなく(metallicが0)、スペキュラがない(ラフネスを1)設定になっています
```js
pbr.baseColor = new BABYLON.Color3(1.0, 0.766, 0.336);
pbr.metallic = 0;
pbr.roughness = 1.0;
```

これを反映させたコードが[こちら](https://playground.babylonjs.com/#2FDQT5)

反射させたい場合は、metallicを1に設定し、ラフネスを0に設定します。
反射を活かすために環境マップを追加します

```js
var pbr = new BABYLON.PBRMetallicRoughnessMaterial("pbr", scene);
pbr.baseColor = new BABYLON.Color3(1.0, 0.766, 0.336);
pbr.metallic = 1.0;
pbr.roughness = 0;
pbr.environmentTexture = BABYLON.CubeTexture.CreateFromPrefilteredData(
  "/textures/environment.dds",
  scene
);
```

これらを反映させたコードが[こちら](https://playground.babylonjs.com/#2FDQT5#11)

![](/images/babylon/2022-04-04-21-51-23.png)

オブジェクトのメタリック感や粗さをより正確に表現するために、metallicRoughnessTextureを指定することもできます。

```js
pbr.baseColor = new BABYLON.Color3(1.0, 0.766, 0.336);
pbr.metallic = 1.0; // set to 1 to only use it from the metallicRoughnessTexture
pbr.roughness = 1.0; // set to 1 to only use it from the metallicRoughnessTexture
pbr.environmentTexture = BABYLON.CubeTexture.CreateFromPrefilteredData(
  "/textures/environment.dds",
  scene
);
pbr.metallicRoughnessTexture = new BABYLON.Texture("/textures/mr.jpg", scene);
```
[mr.jpg](https://playground.babylonjs.com/textures/mr.jpg)の中身はこちら

![](/images/babylon/2022-04-04-22-07-09.png)

結果は[こちら](https://playground.babylonjs.com/#2FDQT5#13)

![](/images/babylon/2022-04-04-22-10-17.png)
# PBRSpecularGlossinessMaterial

Materialに5つの値があります

- diffuseColor/diffuseTexture:
- specularColor:
  - Materialの反射率を示します
- glossiness:
  - 光沢度、反射がどの程度鋭いか
- specularGlossinessTexture:
  - RGBAにて、specular colorのRGBとglossinessをAの両方をピクセル単位で指定します
- environmentTexture:
  - 環境テクスチャ

設定例を示します。
```js
var pbr = new BABYLON.PBRSpecularGlossinessMaterial("pbr", scene);
pbr.diffuseColor = new BABYLON.Color3(1.0, 0.766, 0.336);
pbr.specularColor = new BABYLON.Color3(1.0, 0.766, 0.336);
pbr.glossiness = 0./images/babylon/;
pbr.environmentTexture = BABYLON.CubeTexture.CreateFromPrefilteredData(
  "/textures/environment.dds",
  scene
);
```

これはPBRMetallicRoughnessMaterialの以下の設定と同じです。
```js
var pbr = new BABYLON.PBRMetallicRoughnessMaterial("pbr", scene);
pbr.baseColor = new BABYLON.Color3(1.0, 0.766, 0.336);
pbr.metallic = 1.0;
pbr.roughness = 0./images/babylon/;
pbr.environmentTexture = BABYLON.CubeTexture.CreateFromPrefilteredData(
  "/textures/environment.dds",
  scene
);
```

specularGlossinessTextureはmetallicRoughnessTextureと同様に、スペキュラと光沢を詳細に制御するために使用することができます。

```js
var pbr = new BABYLON.PBRMetallicRoughnessMaterial("pbr", scene);
pbr.diffuseColor = new BABYLON.Color3(1.0, 0.766, 0.336);
pbr.specularColor = new BABYLON.Color3(1.0, 1.0, 1.0);
pbr.glossiness = 1.0;
pbr.environmentTexture = BABYLON.CubeTexture.CreateFromPrefilteredData(
  "/textures/environment.dds",
  scene
);
pbr.specularGlossinessTexture = new BABYLON.Texture("/textures/sg.png", scene);
```
[sg.png](https://playground.babylonjs.com/textures/sg.png)の中身はこちら

![](/images/babylon/2022-04-04-22-29-57.png)

こちらの結果は[こちら](https://playground.babylonjs.com/#Z1VL3V#4)

![](/images/babylon/2022-04-04-22-28-53.png)

# Light設定

動的ライト(Dynamic light)はPBRの設定において重要な要素です。
ライトを持たずに環境マップのみを使用してシーンを照らすこともできますし、レンダリングを向上させるために光源を追加することも可能です。

光の強度について、物理学の概念に従います

デフォルトでは、Light Intensities(光の強度)は、光源からの距離の逆二乗を使用して計算されます。

- Point LightとSpot Light
  - 光度(luminous intensity)(candela, m/sr)で定義されます。
- Directional LightとHemispheric Light
  - 照度(illuminance)(nit, cd/m2)で定義されます。

ダイナミックライティングの仕組みについては、[Mastering PBR](https://doc.babylonjs.com/divingDeeper/materials/using/masterPBR)で説明しています。

とはいえ、まずはhigh dynamic range (HDR) をPBRで使う方法を見ていくとよいでしょう。

https://zenn.dev/iwaken71/articles/babylonjs-hdr-env


# まとめ

この記事は[Introduction to Physically Based Rendering](https://doc.babylonjs.com/divingDeeper/materials/using/HDREnvironment)を参考にし、Babylon.jsにおけるPBRの扱い方をご紹介しました。

今後[イワケン](https://twitter.com/iwaken71)はBabylon.jsの可能性について掘っていきたいと思いますのでよろしくお願いいたします。
