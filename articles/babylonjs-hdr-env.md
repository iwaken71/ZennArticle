---
title: "Babylon.jsでPBR向けHDR環境の扱い方をご紹介 【ドキュメント和訳+α】"
emoji: "🔥"
type: "tech" # tech: 技術記事 / idea: アイデア
topics: ["BabylonJS","JavaScript","HDR"]
published: true
---

# はじめに
この記事は[Using An HDR Environment For PBR](https://doc.babylonjs.com/divingDeeper/materials/using/HDREnvironment)を参考にし、Babylon.jsにおけるPBR向けHDR環境の扱い方をご紹介します。

この記事では

- 環境マップのScript上での扱い方
- 環境マップの生成/変換の仕方

の順番で紹介します。

# 環境マップのScript上での扱い方

環境マップを設定する方法として、プレフィルタリングされたMipMapsを持つCubeTextureを含むHDR対応ファイル (dds or env形式)をBabylonでは推奨しています。

HDR環境を読み込むために、デフォルトで[createDefaultEnvironment](https://doc.babylonjs.com/typedoc/classes/babylon.scene#createdefaultenvironment)を使用することができます。

```js
scene.createDefaultEnvironment();
```

このコードは、assets.babylonjs.comから[environmentSpecular.env](https://assets.babylonjs.com/environments/environmentSpecular.env)ファイルを読み込みます。

カスタムのenv textureを読み込みたい場合は、`scene.environmentTexture`にセットします。

```js
var hdrTexture = BABYLON.CubeTexture.CreateFromPrefilteredData("textures/environment.env", scene);
scene.environmentTexture = hdrTexture;
```
この書き方の場合次のように表示されました。反射が3Dモデルに適用されているのがわかると思います。
![](/images/hololens-2022-2/2022-04-03-23-38-32.png)


また、`createDefaultEnvironment()`の中のoptionに指定することもできます。

```js
scene.createDefaultEnvironment({
    environmentTexture: "texture-url.env"
});
```

:::message
他のOptionについては、[Interface IEnvironmentHelperOptionsのドキュメント](https://doc.babylonjs.com/typedoc/interfaces/babylon.ienvironmenthelperoptions)を参照。

:::

このようなHDR対応ファイル (dds or env形式)を作成するために2つの方法を紹介します。


# 環境マップの生成/変換の仕方

ファイル形式と変換ツールと関係は以下になります。最終的に、.ddsまたは.envファイルを目指します。
![](/images/hololens-2022-2/2022-04-04-19-22-20.png)

## SandBoxによる圧縮された環境マップの作成

生成されたddsファイルは比較的に大きくなるため、Babylon.jsではテクスチャを圧縮パッケージするために.envファイルを生成する手順を提供しています。

- [Sandbox](https://sandbox.babylonjs.com/)を開く
- PBRシーンファイルをドラッグ&ドロップ (glbファイルなど [Sample](https://models.babylonjs.com/PBR_Spheres.glb))
- 環境テクスチャファイル.ddsをドラッグ&ドロップ ([Sample](https://playground.babylonjs.com/textures/environment.dds))
- Inspectorを開き、Toolsを開き、`Generate .env texture`をクリック

![](/images/hololens-2022-2/2022-04-04-17-11-54.png)

.envファイルをダウンロードしたら、このようなコードで使用できます。

```js
scene.environmentTexture = new BABYLON.CubeTexture("environment.env", scene);
```

## IBL Texture Tool

もし、.hdr形式のテクスチャを持っている場合、[IBL Texture Tool](https://www.babylonjs.com/tools/ibl/)を用いて、.envファイルを簡単に変換することができます。

リンクを開くと以下のような画面が開かれます。

![](/images/hololens-2022-2/2022-04-04-17-43-32.png)

ここに、.hdrファイルをドラッグ&ドロップすると、変換され.envファイルがダウンロードされます。

![](/images/hololens-2022-2/2022-04-04-17-45-27.png)

## 外部ツール

- IBL Baker
- Lys

の2つのツールを紹介します。

### IBL Bakerからdds環境マップを生成

https://github.com/derkreature/IBLBaker

こちらのオープンソースになります。

- Githubからclone or Download
  - `/bin64`フォルダから`IBLBaker.exe`を立ち上げる
- `Load enviroment`ボタンから、HDR画像ファイルをアップロード
  - exrファイルも対応可能
- 必要に合わせて設定をいじる
- `Save enviroment`ボタンをクリック
  - ファイル名は拡張子に`.dds`をつけることを忘れずに！

![](/images/hololens-2022-2/2022-04-04-18-28-38.png)


使用するのは SpecularHDRファイルだそうです。
![](/images/hololens-2022-2/2022-04-04-18-30-43.png)

### LYSからdds環境マップを生成

[Lys](https://www.knaldtech.com/lys/)を使うことで、生成されたミップマップの出力品質をUnityのstandard materialに近いroughnessレスポンスより高い水準になります。また、128、256、512px幅のddsキューブテクスチャを生成することができます。

こちら、有料アプリのため私の方では動作を確認していません。

## 直接.hdrファイルを使用したい場合

.envファイルや.ddsファイルへプリフィルタリングできなく、.hdrファイルを直接使用したいケースでは、テクスチャがロードされた瞬間に変換を実行することが可能です。

```js
var reflectionTexture = new BABYLON.HDRCubeTexture("./textures/environment.hdr", scene, 128, false, true, false, true);
```

この方法では、プリフィルタリングをリアルタイムで行われるため、テクスチャの読み込みに若干遅延が発生します。そのため最適なパフォーマンスを得るためには、.envか.ddsファイルを使用するのが望ましいです。またWebGL2である必要があります。
## PureなCube Textureを使用する

.ddsまたは.envのCube Textureを使用するのが最善の選択肢ですが、クラシックなCube Textureに依存したい場合もあります。

```js
scene.environmentTexture = new BABYLON.CubeTexture("textures/TropicalSunnyDay", scene);
```

この場合、HDRレンダリングはできず、いくつかの人工物のようなものが現れるかもしれません。

# まとめ

この記事では[Using An HDR Environment For PBR](https://doc.babylonjs.com/divingDeeper/materials/using/HDREnvironment)を参考にし、Babylon.jsにおけるPBR向けHDR環境の扱い方をご紹介しました。

今後わたくし[イワケン](https://twitter.com/iwaken71)はBabylon.jsの可能性について掘っていきたいと思いますのでよろしくお願いいたします。

