---
title: "UnityからHoloLensへのビルド。これでよかったんや...!"
emoji: "🔥"
type: "tech" # tech: 技術記事 / idea: アイデア
topics: ["Unity","HoloLens"]
published: true
---


# はじめに

こんにちは、XR好きエンジニアのイワケンです。
HoloLensに2017年に出会って6年目な私ですが。UnityからHoloLensへビルドするのに、これでよかったんや...!という気付きを得たので共有します。

# 今までのビルド方法

- UnityでUniversal Windows Platformでビルド
- Visual StudioからデバッグなしでStart

この2段階でした。このVisual Studio開くのが面倒くさかった。。。

https://learn.microsoft.com/ja-jp/windows/mixed-reality/develop/advanced-concepts/using-visual-studio?tabs=hl2

ということで、Unityだけで完結する方法を見つけたので共有します。

# 前提

- 上記のフローでビルドしたことがある。
- Unity2021.3.x
- MRTK2.8

# やり方 Build and Run

- 一度Device Portalにつなぎます。
  - HoloLensのIPアドレスを調べます。
  - HoloLensのIPアドレスをPCのブラウザに入力します。
  - ユーザー名とパスワードを入力すると入れます。

![](/images/hololens/holo.png)

この状態で

UnityのBuild Settingsを開き、

- Build and Run on にて「Remote Device (via Device Portal)」を選択
- Device Portal Address
  - https://{HoloLensのIPアドレス} = Device PortalのURL
  - Device Portal Username
  - Device Portal Password

を入力。

![](/images/hololens/holo2.png)


この状態で「Build and Run」を押すと、直接HoloLensアプリにビルドされます！すばらしい！

