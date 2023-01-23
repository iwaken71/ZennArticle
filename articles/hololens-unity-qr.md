---
title: "Unity×HoloLens2×MRTK×QRCodeをとりあえず動かしたいとき"
emoji: "🔥"
type: "tech" # tech: 技術記事 / idea: アイデア
topics: ["Unity","HoloLens","CSharp","VisualStudio","Microsoft"]
published: true
publication_name: "iwakenlab_book"
---

# ゴールのアウトプット

https://youtu.be/T1HjwqwTOHA


# 手順

- NuGetForUnityをインストール
- Microsoft.MixedReality.QRをインストール
- QRTrackingのSampleをダウンロード&コピー
- XR Plugin Managementをインストール
- 設定を変更
- ビルド！

# 前提

- Unity2019.4.26
- Microsoft Mixed Reality Toolkit 2.6.1

これらがすでに使用されている状態でQRコードによるトラッキングをできるようにしたい。
MRTKとXR Plugin Managementの共存が意外と面倒くさかったので記事にしました。

# NuGetForUnityをインストール

https://github.com/GlitchEnzo/NuGetForUnity

[NuGetForUnityのunitypackageのダウンロードリンク](https://github.com/GlitchEnzo/NuGetForUnity/releases/download/v3.0.2/NuGetForUnity.3.0.2.unitypackage)

unitypackageをダウンロードし、Unityにimportします。

# Microsoft.MixedReality.QRをインストール

- UnityのMenuから[NuGet]>[Mangage NuGet Packages]を選択
- Microsoft.MixedReality.QRで検索
- installをクリック

![image](https://user-images.githubusercontent.com/10010842/121031728-953a5b80-c7e5-11eb-8fce-1ec94e1e725b.png)

# QRTrackingのSampleをダウンロード&コピー

[QRTrackingのGithubリンク](https://github.com/chgatla-microsoft/QRTracking/tree/unity2019)のDownloadからScriptとPrefabsを取得する。

![image](https://user-images.githubusercontent.com/10010842/121042317-84421800-c7ee-11eb-841c-079db793dac3.png)

ダウンロードして展開したら、Assets/QRCode以下にコピーする。

![image](https://user-images.githubusercontent.com/10010842/121043089-485b8280-c7ef-11eb-9adf-35f4b17b418c.png)


# XR Plugin Managementをインストール

UnityのMenuの[Window]>[Package Manager]>[XR Plugin Management]

![image](https://user-images.githubusercontent.com/10010842/121048512-d6d10380-c7f1-11eb-9396-04617908de82.png)

# 設定を変更

## PlayerSettingのCapabilitiesの設定

WebCamにチェックを入れる。

![image](https://user-images.githubusercontent.com/10010842/121059948-ffaac600-c7fc-11eb-82cc-510af3ac74da.png)

## XR Plugin Managementの設定変更

[Edit]>[Project Settings]>[XR Plugin Management]にて

![image](https://user-images.githubusercontent.com/10010842/121054881-bdcb5100-c7f7-11eb-9f65-45ba02b3f4a8.png)

[Edit]>[Project Settings]>[XR Plugin Management]>[Windows Mixed Reality]の設定
![image](https://user-images.githubusercontent.com/10010842/121055547-51048680-c7f8-11eb-8d50-2ea2af5c4c96.png)

## MRTKのProfile設定変更

Scene上のMixedRealityToolkitのProfileを
**DefaultXDSDKConfigurationProfile**を選ぶ。カスタマイズしたい設定は変える。

![image](https://user-images.githubusercontent.com/10010842/121056173-e869d980-c7f8-11eb-8c4a-368b639e0bd8.png)

## QRCodesManagerをシーン上に配置

[QRCode]>[Prefabs]>[QRCodesManager]をScene上に配置する。
![image](https://user-images.githubusercontent.com/10010842/121056655-60380400-c7f9-11eb-8b54-6554d99b3dc3.png)

## ビルド！
ここまできたらHoloLens向けにBuildしたらOK。

# 参考記事

https://xrdnk.hateblo.jp/entry/2020/10/24/181009

https://qiita.com/Futo_Horio/items/83284b6732ce97150181

https://bibinbaleo.hatenablog.com/entry/2020/04/13/203400