---
title: "HoloLens2のMicrosoft Mesh Appに好きな3Dモデルをアップロードする方法"
emoji: "🔥"
type: "tech" # tech: 技術記事 / idea: アイデア
topics: ["HoloLens","MixedReality","Microsoft"]
published: true
---
# 今日のゴール

こんな感じでMicrosoft Mesh AppにUnitychanを登場させます。

![20210304_012505_HoloLens.jpg](https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/96970/8e5a915b-6e2b-190f-9a5d-33c092144c06.jpeg)

https://twitter.com/iwaken71/status/1367150478467813376?s=20

## Microsoft Meshとは

> “You can actually feel like you’re in the same place”: Microsoft Mesh powers shared experiences in mixed reality

MRの世界を共有するプラットフォーム、Microsoft Mesh
米国時間3月2日にMicrosoftのカンファレンスIgniteにて公開されました。
https://news.microsoft.com/innovation-stories/microsoft-mesh/

https://www.youtube.com/watch?v=IkpsJoobZmE&feature=emb_logo

Microsoft Mesh AppはMicrosoft Storeからアプリをダウンロードできます。(HoloLens2にダウンロード)
https://www.microsoft.com/ja-jp/p/microsoft-mesh-app-preview/9p64lj74ngw0?activetab=pivot:overviewtab


# 前提

- HoloLens2のMicrosoft Mesh Appを使用
- OneDriveとHoloLens2のログインMicrosoft Accountは同一 (違う場合どうなるかは未検証)

# 手順

- 3Dモデルをglb形式で準備する
    - Unitychanをglb形式で書き出す
- OneDriveにアップロードする
- HoloLens2のMicrosoft Mesh AppからUnitychanをダウンロード

# 3Dモデルをglb形式で準備する

公式ドキュメントなどは見れていないのですが、今回fbx,glb,[gltf](https://github.com/KhronosGroup/glTF/tree/master/specification/2.0)形式のの3Dモデル形式を調べた結果glb形式のみ認識しました。なので、今回glb形式を準備します。

gltfとglbについては[こちら](https://www.codegrid.net/articles/2018-gltf-1/)

(追記)
[公式ドキュメント](https://docs.microsoft.com/en-us/mesh/mesh-app/)より、現在対応している形式はglb形式のみだそうです。

## Unitychanをglb形式で書き出す

ここは手段は何でもいいのですが、私は

- UnitychanのVRMファイルをダウンロード
- UniVRMからVRMファイルからglb形式にExport

という手段を選びました。

https://3d.nicovideo.jp/works/td33435

https://github.com/vrm-c/UniVRM/releases

# OneDriveにアップロードする

[OneDrive](https://onedrive.live.com/)にログイン後
[自分のファイル]>[アプリ]>[Microsoft Mesh App(Preview)]>[MyContent]を開く

ここにglbファイルを置く。

![image.png](https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/96970/db14bf20-1a98-527c-1ce8-f6bd8627bc50.png)
(試しに他のファイル形式を試した跡)

# HoloLens2のMicrosoft Mesh AppからUnitychanをダウンロード

Microsoft Mesh Appを立ち上げて

[Content]>[One Drive]を選択すると、Unitychanが選択できれば成功です。

作業動画はこちら...!

https://twitter.com/iwaken71/status/1367157890675474435?s=20

# おわりに

Microsoft Mesh非常に楽しみですね...!
今後開発者としても色々手を加えられるようになっていくと予想しているのでとても楽しみです。
引き続きMRの新しいプラットフォームに期待と敬意を示して、記事を書いていきたいと思います。

![20210304_020329_HoloLens.jpg](https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/96970/c1a23c6a-246a-0896-5fbb-6227bb16cfb7.jpeg)


こちらの記事はQiita記事と同様になっております
https://qiita.com/iwaken71/items/a6f89e2aba1cac99efc5






