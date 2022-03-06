---
title: "【HoloLens2×UE4.27】Microsoft OpenXRによるビルドを試してみた"
emoji: "👏"
type: "tech" # tech: 技術記事 / idea: アイデア
topics: [HoloLens,UnrealEngine,Microsoft]
published: false
---
# はじめに

こんにちは、HoloLens好きエンジニアのイワケンです。
Unreal Engine(以下UE)のバージョン4.27でのHoloLens開発をするためにドキュメントをみたところ、**Microsoft OpenXR プラグイン**に対応と書かれておりました。

この記事では、**Microsoft OpenXR プラグイン**でのHoloLens向けビルドするまでの動作を確認します。

https://docs.microsoft.com/ja-jp/windows/mixed-reality/develop/unreal/unreal-development-overview?tabs=ue426%2Cmrtk%2Casa%2CD365

# そもそもOpenXRとは

https://www.khronos.org/openxr/

> OpenXRは、拡張現実（AR）および仮想現実（VR）（総称してXR）プラットフォームやデバイスへの高性能なアクセスを提供するロイヤリティフリーのオープンスタンダードです。

このウェブサイトのこの図がわかりやすいでしょう。
昔は、それぞれのXRデバイスのAPIに対応しないといけなかったのが

![](https://www.khronos.org/assets/uploads/apis/OpenXR-Before_3.png)

OpenXRによって、クロスプラットフォーム対応されます。

![](https://www.khronos.org/assets/uploads/apis/OpenXR-After_3.png)

という感じで、HoloLensだけでなく、OculusQuest2などのVR開発でもOpenXR Pluginの登場により開発環境が変わりつつあります。また、Unreal EngineだけでなくUnityにも対応しています。

## Microsoft OpenXRとは
https://www.unrealengine.com/marketplace/ja/product/ef8930ca860148c498b46887da196239

> The Microsoft OpenXR plugin contains a set of OpenXR extensions unlocking mixed reality-specific features from Microsoft. If you're developing an experience targeting OpenXR for HoloLens 2 or Windows Mixed Reality VR headsets, you'll need this plugin to access the following features:

つまり、MicrosoftのMixed Realityに特化した機能を使用可能にするための、OpenXRの拡張セットになります。

具体的には

- Spatial mapping
- Scene Understanding (requires 4.27.1+)
- Spatial anchors
- Holographic remoting
- Voice input
- Hand mesh
- System keyboard
- Camera
- QR code tracking
- Azure Spatial Anchors
- Secondary View Configuration (requires 4.26.2+)

といった機能がOpenXRの拡張として使用することができるようになります。

# 筆者の環境

|項目|OS|
|---|---|
|OS|Windows11 Home|
|Unreal Engine|4.27.2|
|Visual Studio|2022|
|Microsoft OpenXR|1.1.8|

# 今回やること

今回基本的にやることは下記の記事と同じです。
Cubeを出すアプリをHoloLens2にビルドします。

https://zenn.dev/iwaken71/articles/6792badbdec8d6

なので、セットアップなど共通な部分はこの記事では割愛します。

上記の記事と今回の記事で違う部分は

> 以下のPluginを有効化しUE4を再起動する (UE4ではPluginの有効化に再起動が必要)
> - HoloLens
> - Microsoft Windows Mixed Reality

この部分について[Microsoft Windows Mixed Reality]ではなく[Microsoft OpenXR]を選択するということです。

この記事では、この部分に焦点を当てて、具体的にどうやるのか書いていきます。

# 手順

- MarketPlaceから[Microsoft OpenXR]をダウンロードする
- [Microsoft OpenXR]にチェックをつける
- [Microsoft Windows Mixed Reality]のチェックを外す

この手順になります。


## MarketPlaceから[Microsoft OpenXR]をダウンロードする

UnrealEngineのMarketPlace(UnityでいうAssetStoreみたいなもの)から[Microsoft OpenXR [外部リンク]](https://www.unrealengine.com/marketplace/ja/product/ef8930ca860148c498b46887da196239)をエンジンにインストールする。

![](https://storage.googleapis.com/zenn-user-upload/8e343d8f816c-20220306.png)

インストールが終わったら、Unreal Engineプロジェクトを開き[Edit]>[Plugin]を開き「Microsoft」で検索。

すると
- Microsoft OpenXR
- Microsoft Windows Mixed Reality

が現れるので、[Microsoft OpenXR]にチェックをいれて、[Microsoft Windows Mixed Reality]のチェックを外す。
![](https://storage.googleapis.com/zenn-user-upload/829ba2b2cead-20220306.png)

この状態でUnreal Engineを再起動。
あとは、[【HoloLens2】UnityエンジニアがUE4.26でHoloLens2に豆腐(Cube)ビルドする](https://zenn.dev/iwaken71/articles/6792badbdec8d6
)に沿って進めてPackage (Build) まで行います。

[Holographic Remotingで確認](https://docs.microsoft.com/ja-jp/windows/mixed-reality/develop/unreal/tutorials/unreal-uxt-ch6)するとこちら

![](https://storage.googleapis.com/zenn-user-upload/a81cac9d9bf5-20220307.gif)

# 注意点
:::message alert
[Microsoft Windows Mixed Reality]と[Microsoft OpenXR]2つともチェックを入れた状態で、HoloLens向けにビルドするとエラーが出ることを確認
:::
具体的には

```
UATHelper: Packaging (HoloLens):     MixedRealityInteropHoloLens.lib(CameraImageCapture.obj) : error LNK2038: 'C++/WinRT version' �̕s��v�����o����܂����B�l '2.0.201113.7' �� 2.0.201217.4 �̒l 'PCH.MicrosoftOpenXR.h.obj' �ƈ�v���܂���B
UATHelper: Packaging (HoloLens):     MixedRealityInteropHoloLens.lib(SpatialAnchorHelper.obj) : error LNK2038: 'C++/WinRT version' �̕s��v�����o����܂����B�l '2.0.201113.7' �� 2.0.201217.4 �̒l 'PCH.MicrosoftOpenXR.h.obj' �ƈ�v���܂���B
UATHelper: Packaging (HoloLens):     MixedRealityInteropHoloLens.lib(HandMeshObserver.obj) : error LNK2038: 'C++/WinRT version' �̕s��v�����o����܂����B�l '2.0.201113.7' �� 2.0.201217.4 �̒l 'PCH.MicrosoftOpenXR.h.obj' �ƈ�v���܂���B
UATHelper: Packaging (HoloLens):     MixedRealityInteropHoloLens.lib(MeshObserver.obj) : error LNK2038: 'C++/WinRT version' �̕s��v�����o����܂����B�l '2.0.201113.7' �� 2.0.201217.4 �̒l 'PCH.MicrosoftOpenXR.h.obj' �ƈ�v���܂���B
UATHelper: Packaging (HoloLens):     MixedRealityInteropHoloLens.lib(SceneUnderstandingObserver.obj) : error LNK2038: 'C++/WinRT version' �̕s��v�����o����܂����B�l '2.0.201113.7' �� 2.0.201217.4 �̒l 'PCH.MicrosoftOpenXR.h.obj' �ƈ�v���܂���B
UATHelper: Packaging (HoloLens):     MixedRealityInteropHoloLens.lib(QRCodeObserver.obj) : error LNK2038: 'C++/WinRT version' �̕s��v�����o����܂����B�l '2.0.201113.7' �� 2.0.201217.4 �̒l 'PCH.MicrosoftOpenXR.h.obj' �ƈ�v���܂���B
UATHelper: Packaging (HoloLens):        ���C�u���� D:\workplace\UnrealEngine\HoloLensApp\Binaries\HoloLens\HoloLensApparm64.lib �ƃI�u�W�F�N�g D:\workplace\UnrealEngine\HoloLensApp\Binaries\HoloLens\HoloLensApparm64.exp ��쐬��
UATHelper: Packaging (HoloLens):     D:\workplace\UnrealEngine\HoloLensApp\Binaries\HoloLens\HoloLensApparm64.exe : fatal error LNK1319: 7 �̕s��v�����o����܂���
```

のようなエラーを確認しています。

# 今後の展望

この記事では、[Microsoft Windows Mixed Reality]と[Microsoft OpenXR]の違いがどのような影響を及ぼすかということまでは調べていません。今後調査したいと思います。