---
title: "【自称最速】Unreal Engine5.0のリリース直後にHololens 2ビルドできるか試してみた"
emoji: "🔥"
type: "tech" # tech: 技術記事 / idea: アイデア
topics: ["UnrealEngine","HoloLens","Microsoft"]
published: true
---

# はじめに
2022年4月6日にUnreal Engine5.0 (以下UE5)がリリースされました。それまではプレビュー版でしたが正式版でリリースされてました。

https://docs.unrealengine.com/5.0/ja/unreal-engine-5-0-release-notes/

UE5はLumen のグローバルイルミネーションなど、期待されている機能が多く、注目度が高かったかと思います。

その中でHoloLens 2開発のサポートがどうなっているのか気になって調査してみました！
ちなみに、UE4.25~4.27ではHoloLens 2での開発をサポートしています。

# 結論

[過去の記事](https://zenn.dev/iwaken71/articles/6792badbdec8d6)のUE4.26によるHoloLensビルドの手順を確認しながら、
UE5からHoloLens 2向けのビルドをすること自体はできました。

https://youtu.be/zk62GvoDIb4

しかし

- [MixedReality-UXTools-Unreal](https://github.com/microsoft/MixedReality-UXTools-Unreal)という(UnityでいうMRTKにあたるもの)が2022年4月6日現在ではUE5対応できていない状況です
  - したがって、ハンドトラッキングなどのHoloLens2の開発をスムーズに行うことは難しいです。
- 開発フローで大きな変更が一つあります
  - HoloLens Pluginのチェックが不要になりました
- 2022年4月6日現在ではWindows11で、Microsoft Windows Mixed Realityプラグインが使用不可。Windows10であれば可能

# MixedReality-UXTools-UnrealのUE5対応状況について

Githubを見たところ、UE5対応の[issue](https://github.com/microsoft/MixedReality-UXTools-Unreal/issues/46)は上がっていました。

正式リリース前の調査としてこちらのブランチが使用されていたようです。
https://github.com/microsoft/MixedReality-UXTools-Unreal/tree/public/0.12.x-UE5.0


開発自体は進んでいるものの、最終コミットが2021年11月19日。3ヶ月以上止まっているので、正式リリースとなった今、進むかどうか (もはや、検証してfixしてプルリク送ってもいいかもしれない)

UMG (UnityでいうUI)やシェーダー回りにバグがあるようです。

# HoloLens プラグインのチェックが不要

https://docs.unrealengine.com/5.0/ja/unreal-engine-5-0-release-notes/

より

> HoloLens プラグインとそのすべての機能は Unreal Engine 5 に完全に統合されました。このため、HoloLens プラグインは不要になり、これをプロジェクトに追加することもできなくなりました。HoloLens プラグインを使用する既存のプロジェクトがある場合は、UE5 へのアップグレード後に初めてそのプロジェクトを開いた際に、このプラグインのコンフィグ データを削除するよう Unreal Engine 5.0 に促されます。

ということで、UE4.25~4.27で必要だったHoloLensプラグインのチェックは不要になります。

# Microsoft Windows Mixed Realityプラグイン

HoloLensから没入感ある体験をするためには、Microsoft Windows Mixed Realityプラグインのチェックが必要です。しかし、私の家のPCのWindows11では使用不可でした (今後改善される可能性はあります) なので、今回はWindows10の別PCでビルドすることで解決しました。

# UE5のEditor変更点

特に変わったところを2つ紹介。

## Ctrl+Spaceで、コンテンツブラウザが立ち上がります

![](/images/babylon/2022-04-06-07-54-33.png)

## Package (Build)のボタン位置の変更

再生ボタンの右側にPlatformというボタンがあるので、そこからPackage作業を行います。

![](/images/babylon/2022-04-06-07-52-32.png)

# まとめ

待望のUE5で早速HoloLensビルドができて個人的にはテンションが高まりました。
現状ではHoloLens開発のために必要な主要プラグインがUE5に対応してないのですが、今後対応されていくと思います。また対応がされたら記事を書いていきたいと思います。
