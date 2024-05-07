---
title: "Let's Apple Vision Pro! Sampleから学ぶPolySpatialのXR機能紹介"
emoji: "👓"
type: "tech" # tech: 技術記事 / idea: アイデア
topics: ["Unity","AppleVisionPro"]
published: false
---

こんにちは、サイバーエージェントのXR研究所の[イワケン](https://twitter.com/iwaken71)です。

「XRを啓蒙し、事業のタネを作る」をミッションにXRの体験会、勉強会、プロトタイピングなどを行っています。

この記事では、UnityのPolySpatialのSampleからvisionOS向けのXR機能の紹介を行います。(社内visionOS勉強会で発表した内容をZennに記事化しました)

Apple Vision Proでの実機での動作も共有しますので、お楽しみに。

# 開発環境

私が検証した開発閑居はこちらです。

|ツール|バージョン|
|---|---|
|Unity|2022.3.18|
|PolySpatial|1.1.6|
|Xcode|15.2|
|visionOS|1.0.2 Beta|

# Unity PolySpatial開発の前提の話

## Unity PolySpatialとは

UnityでvisionOS向けアプリを作成するためのパッケージです。
visionOS向けのプロジェクトのビルドをUnityエディタから行います。


- ① Mixed Reality
  - Volume
  - Immersive Space
- ② Virtual Reality - Fully Immersive
- ③ Windowed Apps

のアプリパターンを作成できます。

![](/images/avp/2024-05-07-13-03-50.png)
*引用:[UNITE2023 Unity PolySpatial + visionOS について知っておきたいすべてのこと](https://www.youtube.com/watch?v=o8EfcQHbJqo)*

本記事では **②Mixed Reality** に該当するアプリパターンのSampleを紹介します。

## VolumesとSpacesの違い

![](/images/avp/2024-05-07-12-50-05.png)
*引用:[WWDC2023,Get started with building apps for spatial computing](https://developer.apple.com/videos/play/wwdc2023/10260/)*

Apple Vision ProにはVolumesとSpacesの2つのアプリパターンがあります。

- **① Volumes (Shared,Bounded)**
  - 箱型で他のアプリと共存できる
  - **ARkitの機能は使えない**
  - 入力は3DTouchに限定
- **② Spaces (Exclusive,Unbounded)**
  - そのアプリ単体の空間になる
  - **ARkitの機能が使用可能**
    - 平面検知
    - ハンドトラッキング
    - etc...

:::message
ドキュメント: [PolySpatial Mixed Reality apps on visionOS](https://docs.unity3d.com/Packages/com.unity.polyspatial.visionos@1.2/manual/PolySpatialMRApps.html)からの参考
:::

# Sampleを眺めてXR機能紹介

## Sampleの習得の仕方

![](/images/avp/2024-05-07-13-13-28.png)



