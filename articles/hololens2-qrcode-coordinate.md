---
title: "【HoloLens2】UE4.26でQRCode Trackingの座標軸に合わせてActorを出現させる"
emoji: "🔥"
type: "tech" # tech: 技術記事 / idea: アイデア
topics: ["UnrealEngine","HoloLens","UE4","VisualStudio","Microsoft"]
published: true
---

# はじめに

[前回の記事](https://zenn.dev/iwaken71/articles/25e1b57e2f5b3420dd5c)で、QRCode上にCubeを出現させてみました。
この記事では、向きを調整して出現させる方法について書きます。

# 完成物
このようにQRCodeに対して想定通りの向きで出現してくれれば成功です。
![ChairQR2](https://user-images.githubusercontent.com/10010842/103862436-73d42700-5102-11eb-93d0-4717723be12a.gif)

# 開発環境

- Windows10 Pro
- Unreal Engine4.26 (以下Unreal)
- Visual Studio2019
- HoloLens2

# 前準備

今回はこちらの記事の続きとなります。
https://zenn.dev/iwaken71/articles/25e1b57e2f5b3420dd5c

# 手順

- MarketPlaceから好きなAssetを追加する
- QRTrackingしたらAssetが表示されるようにする
- 一旦Package化
- 座標軸の調整
- 再Package化

# MarketPlaceから好きなAssetを追加する

- [Epic Games Launcher]アプリを起動する
- [Unreal Engine]>[マーケットプレイス]を選択
    - [無料]などでフィルターを行いお好みのAssetを見つける
        - 今回[Broadcast Studio]というAssetを使わせていただきました。ありがとうございます。
    - サポートされているプラットフォーム、バージョン、[アセットタイプ]かどうかを確認
    - [無料]>[プロジェクトに追加する]を選択  
- 追加先のプロジェクトを選択し、[プロジェクトに追加]を選択
- Unrealを開き、追加されていることを確認


## [Unreal Engine]>[マーケットプレイス]を選択
![image](https://user-images.githubusercontent.com/10010842/103850880-bfc7a180-50eb-11eb-8c95-95d1324fcf74.png)

## [プロジェクトに追加する]を選択  
![image](https://user-images.githubusercontent.com/10010842/103851191-7d529480-50ec-11eb-85fa-db616e89ba60.png)
## 追加先のプロジェクトを選択し、[プロジェクトに追加]を選択
![image](https://user-images.githubusercontent.com/10010842/103851282-c276c680-50ec-11eb-9d1b-a3d7bcba17e8.png)
## Unrealを開き、追加されていることを確認
![image](https://user-images.githubusercontent.com/10010842/103851664-a162a580-50ed-11eb-8c22-e483c3d6651e.png)

# QRTrackingしたらAssetが表示されるようにする

- ViewPortに配置
    - [Content]>[BroadcastStudio]>[Meshes]以下の[SM_BS_Guest_Chair]を選択
    - ViewPortにドラッグ&ドロップ
- Transformを調整
    - Location:0,0,0
    - Scale:0.1,0.1,0.1
    - Mobility:**Movableに設定**
- [Outliner]上の[BP_QRCodeTrackingManager]を選択し[Details]画面で[Default]>[Cube]を[SM_BS_Guest_Chair]に変更
    - [BP_QRCodeTrackingManager]の設定は[前回の記事](https://zenn.dev/iwaken71/articles/25e1b57e2f5b3420dd5c)の引継ぎになります。

## ViewPortに配置, Transformを調整
![image](https://user-images.githubusercontent.com/10010842/103852277-e63b0c00-50ee-11eb-9594-a82211ae1cba.png)
## [Outliner]上の[BP_QRCodeTrackingManager]を選択し[Details]画面で[Default]>[Cube]を[SM_BS_Guest_Chair]に変更
![image](https://user-images.githubusercontent.com/10010842/103852377-17b3d780-50ef-11eb-8405-cb536d5d32f9.png)

# 一旦Package化して確認

![ChairQR](https://user-images.githubusercontent.com/10010842/103853650-f7394c80-50f1-11eb-9eeb-21faa428f4ec.gif)

これを見る限り向きが90度回転していますね。

## 参考

座標軸を可視化したオブジェクトを表示するとこのようになります。
![Coordinate](https://user-images.githubusercontent.com/10010842/103857157-459e1980-50f9-11eb-9dde-ee20a71236b9.gif)

# 座標軸の調整

上記の結果から、Y軸90度ズレていることがわかった。QRコードをかざしたときに、目的の位置にするようにするために以下のように[BP_QRCodeTrackingManager]を編集する

Transform Rotationのノードを`(0,-90,0)`に設定する。

![image](https://user-images.githubusercontent.com/10010842/103861931-7da95a80-5101-11eb-86ff-e1434d2e59e7.png)

# 再Package化

無事、想定通りの向きで椅子が出てきました。
![ChairQR2](https://user-images.githubusercontent.com/10010842/103862436-73d42700-5102-11eb-93d0-4717723be12a.gif)

## 補足

最初のChiarの出現時に「チカチカ」表示されていた現象に対して、このようにEmpty Actorの子供にMeshのActorを置くと、改善されました。(理由はまた分析します)
![image](https://user-images.githubusercontent.com/10010842/103862659-dcbb9f00-5102-11eb-954e-efd13a61ba88.png)

さらにActorのそのままのScaleで出現してもらうために[BP_QRCodeTrackingManager]を以下のように書き換えました。
![image](https://user-images.githubusercontent.com/10010842/103862768-0aa0e380-5103-11eb-8809-1cb48f9cdab3.png)

ここらへんは目的に合わせて使い分けてください。