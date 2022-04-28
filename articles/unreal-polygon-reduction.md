---
title: "Unreal Engine4の標準機能でメッシュのポリゴン数を減らして3Dデータをエクスポート"
emoji: "🔥"
type: "tech" # tech: 技術記事 / idea: アイデア
topics: ["UnrealEngine"]
published: false
---

[Uneral Engine](https://www.unrealengine.com/ja/)は、主にゲーム向けのリアルタイム3D制作ツールになります。最近はゲームだけでなく、映像制作や建築にも使われるようになってきました。

![](/images/babylon/2022-04-27-17-18-31.png)

最近はメタバースブームもあり、Web上での3D制作の需要が増えつつあります。Web上の3D制作では[glTF形式](https://knowledge.shade3d.jp/knowledgebase/gltf%E3%81%A8%E3%81%AF)の3Dモデルを扱うことが多いです。

glTF形式のエクスポートについては[glTF ExporterでUnreal EngineからglTFデータ・glbデータをエクスポートする方法](https://zenn.dev/iwaken71/articles/unreal-gltf-exporter)という記事で紹介させていただきました。

一方で、Web上の3D制作では映像制作に比べて大幅にデータサイズを削減する必要があります。例えば8thWallのWebAR開発のドキュメントでは目安として**10MB/35000ポリゴン**まで落とした方が良いと書かれています。

https://qiita.com/iwaken71/items/a735847da783a8367bbd

ここまでデータサイズを削減するには

- ポリゴン数の削減
- テクスチャサイズの削減

のどちらか or どちらもする必要があります。

この記事では、UE4の標準機能でポリゴン数を削減する方法を共有します。

## 手順

- Unreal Engineの準備
- MeshReductionPluginの設定
- StaticMeshの設定
  - Convert Actors To Static Mesh (Option)
  - LODの設定
  - Reduction Setting
- Export

# 用語説明: Level of Detail(LOD)

遠くの場合ポリゴンの少ないモデルに切り替えて、描画負荷を減らす手法になります。

![](/images/babylon/2022-04-28-11-51-33.png)

参考: [Fortniteを支える技術](https://www.slideshare.net/EpicGamesJapan/fortnite-97791917)



# Unreal Engineの準備

Unreal EngineはEpic Games Launcherというアプリからインストールします。

https://www.unrealengine.com/ja/download

こちらから取得します。

今回の記事はバージョン4.27にて検証しています。

# MeshReductionPluginの設定

ポリゴン数削減においてどのPluginを使用するか設定します。

メニューバーから **[Edit]>[Project Settings]>[Editor]>[Mesh Simplification]>[Mesh Reduction Plugin]** を確認します。

UE4では

- QuadricMeshReduction (UE4内製ツール)
- [Simpolygon](https://www.simplygon.com/) (事前インストール必要)

2つの選択肢のポリゴン数削減ツールがあります。

今回はデフォルトでありUE4内製であるQuadricMeshReductionを使うこととします。

# StaticMeshの設定

今回ポリゴン数削減の対象とするのはStaticMeshにします。

## Convert Actors To Static Mesh (Option) で1つのMeshに結合する

複数のStatickMeshからなるActorに関しては、結合してからポリゴン数削減したほうが工数的には楽になりますし、計算処理も少なくなります。

![](/images/babylon/2022-04-28-12-04-19.png)

やり方は

- World Outlinerで結合したいActorをすべて選択する
- 右クリックで **[Convert Actors To Static Mesh]**を選択
- 保存場所を指定

という順番になります。

![](/images/babylon/2022-04-28-12-20-58.png)

生成されたら、コンテンツブラウザからStaticMeshを選択しましょう。

## LODの設定

まず、LODをいくつまで増やすか設定します。
今回は

- LOD 0 (オリジナル)
- LOD 1 (ポリゴン数削除用)

にしたいので「2」つ準備します。

- StaticMeshを開く
- **LOD Settingsカテゴリー**
  - **Numver of LODs**
    - 今回は「2」を記入
  - **Apply Changes**を選択

![](/images/babylon/2022-04-28-12-31-06.png)

## Reduction Setting

LODの数を設定できたら、LOD1にポリゴン数を減らしたメッシュを設定します。

- **LOD Pickerカテゴリー**で **[LOD]>[LOD1]を選択**
- LOD1カテゴリーを開く
  - **Reduction Settings**を開く
    - **Terminiation**
      - Trianglesを選択 (ポリゴン数の削減の場合)
    - **Percent Triangles**
      - 何%まで削減するか選択
      - 今回30%まで削減すると決めて「30」と入力
    - **Welding Threshold**
      - 2つの頂点の距離がこの値より小さい場合、それらは結合されます。
    - **BaseLOD**
      - 元となるLOD。今回は0
- **[Apply Changes]で変更を反映**

![](/images/babylon/2022-04-28-12-39-17.png)

これにより、LOD1のポリゴン数が削減されました。

# エクスポート

[glTF ExporterでUnreal EngineからglTFデータ・glbデータをエクスポートする方法](https://zenn.dev/iwaken71/articles/unreal-gltf-exporter)

参考にExport作業を行います。
- **[StaticMeshを右クリック]>[Asset Action]>[Export]**
- glbまたはglTFを選択
- **[Default Level Of Detail]で「1」を選択 (重要)**

![](/images/babylon/2022-04-28-12-49-27.png)

これで無事にポリゴン数がが削減された3Dデータをエクスポート出来ました！

# 今後への課題

- LODの設定についてはまだベストプラクティスを探っている途中です。あくまで一例の設定のやり方として認識していただけるとありがたいです。

# 参考ページ
https://docs.unrealengine.com/4.27/ja/WorkingWithContent/Types/StaticMeshes/LOD/

https://www.slideshare.net/EpicGamesJapan/fortnite-97791917
