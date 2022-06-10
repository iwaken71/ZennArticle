---
title: "MRTK3のハンドトラッキングサンプルをビルドする【2022.06時点】"
emoji: "🔥"
type: "tech" # tech: 技術記事 / idea: アイデア
topics: ["HoloLens","Untiy","OpenXR"]
published: false
---


2022/6/8に MRTK3 のパブリックプレビューが公開されました。

![](https://res.cloudinary.com/zenn/image/fetch/s--MKjkTXNq--/c_limit%2Cf_auto%2Cfl_progressive%2Cq_auto%2Cw_1200/https://docs.microsoft.com/ja-jp/windows/mixed-reality/mrtk-unity/mrtk3-overview/images/mrtk_ux_v3_cover.png)

わくわく！触りたい！
しかし、どこから触れば...
というあなたに「ハンドトラッキングサンプル」です。

https://twitter.com/iwaken71/status/1535162734127759361?s=20&t=Upe2YGiHliUwDhIzLO6nbw


こちらはGithubに公開されていますので、サクッと試すための手順をご紹介します。
# 筆者の環境

- Windows10
- Unity2020.3.35f1
- VisualStudio2022

:::message
Toolのインストール
:::
# 手順

- githubからclone
- Profile設定
- ビルド
# githubからclone

https://github.com/microsoft/MixedRealityToolkit-Unity/tree/mrtk3

今回こちらのレポジトリをcloneします。

```
git clone git@github.com:microsoft/MixedRealityToolkit-Unity.git
```

UnityのSampleプロジェクトは

`MixedRealityToolkit-Unity/UnityProjects/MRTKDevTemplate`

にありますので、Unityで開きます (Unity2020.3.35f1がオススメです)

# 参考ページ

- [MRTK3（パブリックプレビュー） Hello World!](https://zenn.dev/hiromu/articles/20220609-mrtk3helloworld)
- [MRTK3のドキュメントを読む](https://zenn.dev/iwaken71/scraps/c2d86427e94e2a)
- [公式ドキュメント](https://docs.microsoft.com/ja-jp/windows/mixed-reality/mrtk-unity/mrtk3-overview/)
- [Github MixedRealityToolkit-Unity mrtk3ブランチ](https://github.com/microsoft/MixedRealityToolkit-Unity/tree/mrtk3)