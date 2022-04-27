---
title: "glTF ExporterでUnreal EngineからglTFデータ・glbデータをエクスポートする方法"
emoji: "🔥"
type: "tech" # tech: 技術記事 / idea: アイデア
topics: ["UnrealEngine","glTF"]
published: true
---

# はじめに

[Uneral Engine](https://www.unrealengine.com/ja/)は、主にゲーム向けのリアルタイム3D制作ツールになります。最近はゲームだけでなく、映像制作や建築にも使われるようになってきました。

![](/images/babylon/2022-04-27-17-18-31.png)

最近はメタバースブームもあり、Web上での3D制作の需要が増えつつあります。Web上の3D制作では[glTF形式](https://knowledge.shade3d.jp/knowledgebase/gltf%E3%81%A8%E3%81%AF)の3Dモデルを扱うことが多いです。

しかし、Unreal EngineにはデフォルトではglTF形式のエクスポート機能を持っていません。行うためには[glTF Exporter](https://www.unrealengine.com/marketplace/ja/product/gltf-exporter?sessionInvalidated=true)などの外部プラグインを使用する必要があります。

この記事では、[glTF Exporter](https://www.unrealengine.com/marketplace/ja/product/gltf-exporter?sessionInvalidated=true)の使い方を中心に

- Unreal Engineの準備
- [glTF Exporter](https://www.unrealengine.com/marketplace/ja/product/gltf-exporter?sessionInvalidated=true)のインストールの仕方
- glTF Exporterの使い方
  - レベル全体をエクスポート
  - レベルから選択したアセットをエクスポート
  - コンテンツブラウザのアセットをエクスポート
- glTF Export Optionsで確認する項目
- 実際にエクスポートしたglTF形式のデータの確認の仕方

についてご紹介します。
Unreal Engineが初めての方にもわかりやすい説明を心がけます。

# 用語説明・glTFデータとglbデータ

glTFデータ、glbデータは、3Dデータのjpg形式と呼ばれるほど、どのソフトでも利用ができるほか、sketchfabやパソコンでも3Dデータにしっかりマテリアルがくっついた状態でデータも見ることができるデータ形式です。

用途としては、Webブラウザ上で3Dモデルを扱う際に用いられるよく使われるフォーマットです。

glbデータはglTFのバイナリ形式であり、テクスチャを外部ファイルを参照することなく同梱することができます。
# Unreal Engineの準備

Unreal EngineはEpic Games Launcherというアプリからインストールします。

https://www.unrealengine.com/ja/download

こちらから取得します。

glTF Exporterを使用できるバージョンは4.25~4.27になります。
UE5では2022年4月現在では使用できないので、バージョン4.27を使用しましょう。

![](/images/babylon/2022-04-27-17-29-32.png)

# [glTF Exporter](https://www.unrealengine.com/marketplace/ja/product/gltf-exporter?sessionInvalidated=true)のインストールの仕方

Unreal Engineではマーケットプレイスから外部Pluginをインストールすることができます。

https://www.unrealengine.com/marketplace/ja/product/gltf-exporter?sessionInvalidated=true

こちらにアクセスし

- ランチャーで開く
- エンジンにインストールする
  - 4.27など、自分が使用しているバージョンを選択

でインストールしましょう。
ボタンを押したら[ライブラリ]のタブからインストールされている確認しましょう。

![](/images/babylon/2022-04-27-17-33-39.png)

## glTF Exporterプラグインを有効にする

では、glTF書き出ししたいプロジェクトを開きましょう。

Unreal Engineではプロジェクトごとに使用するPluginを有効する必要があります。

メニューバーの[Edit]>[Plugins]を選択し、Pluginsウィンドウを開きます。

ALLを選択し、検索窓で「glTF」で検索し、

- glTF Exporter
- glTF Importer (glTFのimportが必要ならば)

の Enabledをチェックして Unreal Engineを再起動します。

![](/images/babylon/2022-04-27-17-41-10.png)

# glTF Exporterの使い方

では、glTF形式で出力しましょう。2つの使い方があります。

- レベル全体(UnityでいうScene)のアセットを出力
- 選択したアセットのみ出力

## レベル全体(UnityでいうScene)のアセットを出力

まず、出力したいレベルを開きます。

そこから、メニューバーから[File]>[Export All]をクリックします。

![](/images/babylon/2022-04-27-18-37-02.png)

ファイルの種類でglTFまたはglbを選択します。
今回は1つのファイルにまとまって欲しいのでglbを選択しました。

![](/images/babylon/2022-04-27-18-48-05.png)

すると、[glTF Export Options]ウィンドウが開きます。

このまま何も設定を変えずにExportしてもよいのですが、よく触る設定を共有します。

![](/images/babylon/2022-04-27-18-50-22.png)

## 選択したアセットをglTFにエクスポートする

シーン全体ではなく、一部をエクスポートしたいときもあります。

例えば、この机と椅子と小物をワンセットでglTFエクスポートしたいとしましょう。

そのためには

- エクスポートしたいActor (UnityでいうGameObject)を選択する
- [File]>[Export Selected]を選択する。

![](/images/babylon/2022-04-27-19-22-59.png)

あとは先ほどの手順と同じでエクスポートできます！

![](/images/babylon/2022-04-27-19-28-08.png)

## コンテンツブラウザからglTFにエクスポートする

Unreal EngineのコンテンツブラウザはUnityでのProjectブラウザに当たります。

エクスポートしたいアセットを選択し **[右クリック]>[Asset Actions]>[Export]** を選択します。

![](/images/babylon/2022-04-27-19-31-46.png)

# glTF Export Optionsで確認する項目

基本方針は、データサイズを軽くするために、不要な項目は入れない、不必要にデータサイズを大きくしない、といった方針が妥当だと思います。
特にWebブラウザ上の表現を行う場合はデータサイズやテクスチャサイズなどに気を付けましょう。

- General
  - **Export Uniform Scale**
    - デフォルトでは0.01で問題ないが、Scaleが違う場合は調整する
- Material
  - **Default Material Bake Size**
    - Webに活用する場合は適切にサイズダウンした方がいいと思っています。
      -  WebARの場合、全体ファイルサイズを10MB程度目安
- Mesh
  - **Default Level Of Detail**
    - LODの設定をしている場合確認する
- Scene
  - **Export ○○**
    - 含めたくないものにチェックが入っていないか確認します。

# 実際にエクスポートしたglTF形式のデータの確認の仕方

エクスポートしても、どんな見た目かすぐにはわかりません。
Viewerと呼ばれるWebサイトやアプリを使うことで確認することができます。

例えば

- [glTF Viewer](https://gltf-viewer.donmccurdy.com/)
- [Babylon.js Sandbox](https://sandbox.babylonjs.com/)

など、私は使用しています。
試しに [Babylon.js Sandbox](https://sandbox.babylonjs.com/)を開き、ドラッグ&ドロップすると以下のように表示されます。

レベル全体をエクスポートしたデータはこちら。
![](/images/babylon/2022-04-27-19-10-06.png)

部分的にエクスポートしたデータはこちら。
![](/images/babylon/2022-04-27-19-36-54.png)


ちなみにglTF形式の場合、このように複数のファイルが生成されるのですが

![](/images/babylon/2022-04-27-19-14-47.png)

- gltfファイル
- .binファイル
- Textureファイル群

をすべて、ドラッグ&ドロップすることでViewerで見ることができます。

![](/images/babylon/2022-04-27-19-17-47.png)


# 注意点・今後の課題

Unreal Engineを使っている人にとっては便利な機能なのですが、時と場合によりエラーが発生する場合があります。

例えば、今回のデータでも"VALUE_NOT_IN_RANGE"といったエラーが出ています。これはUnreal Engineのパラメータの範囲とglTFが定めているパラメータの範囲が違うために起きるエラーです。

このようなエラーの対応に対しては今後調査していきます。

```json
{
  "uri": "Desk.glb",
  "mimeType": "model/gltf-binary",
  "validatorVersion": "2.0.0-dev.3.5",
  "validatedAt": "2022-04-27T10:27:07.352Z",
  "issues": {
    "numErrors": 3,
    "numWarnings": 0,
    "numInfos": 9,
    "numHints": 0,
    "messages": [
      {
        "code": "VALUE_NOT_IN_RANGE",
        "message": "Value 2 is out of range.",
        "severity": 0,
        "pointer": "/materials/0/emissiveFactor/0"
      },
      {
        "code": "VALUE_NOT_IN_RANGE",
        "message": "Value 2 is out of range.",
        "severity": 0,
        "pointer": "/materials/0/emissiveFactor/1"
      },
      {
        "code": "VALUE_NOT_IN_RANGE",
        "message": "Value 2 is out of range.",
        "severity": 0,
        "pointer": "/materials/0/emissiveFactor/2"
      },

      ...
```

# 使用したアセット

[Low Poly Medieval Interior and Constructions](https://www.unrealengine.com/marketplace/ja/product/low-poly-medieval-interior-and-constructions#:~:text=A%20Low%20Poly%20Medieval%20Interior,the%20interiors%20in%20any%20configuration.)

