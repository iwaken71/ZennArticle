---
title: "Azure Spatial Anchorsでの位置固定をHoloLens,iOS,Androidで眺めるところまで一気通貫"
emoji: "🔥"
type: "tech" # tech: 技術記事 / idea: アイデア
topics: ["Unity","HoloLens","Azure"]
published: true
---
# 概要
Azure Spatial Anchorsは、空間を認識した位置固定や複数デバイスでのアンカー共有を可能にするMicrosoftが提供するサービスです。

![](https://docs.microsoft.com/ja-jp/azure/spatial-anchors/media/cross-platform.png)

https://docs.microsoft.com/ja-jp/azure/spatial-anchors/overview

習得するために、Microsoft Learnの[Azure Spatial Anchors を使用して実世界のオブジェクトを固定する](https://docs.microsoft.com/ja-jp/learn/modules/azure-spatial-anchors-tutorials/)を進めていると、途中で **「ここはこのページを参考にしてください」** など、他のWebページに飛ぶ場合があります。
初めてのAzure Spatial Anchorに取り組む場合 **「どこまで取り込めばいいんだろう...?」** と不安になることがあります。

この記事では **一気通貫** をコンセプトに、HoloLensとiOS,AndroidでAzure Spatial Anchorを使って位置固定するところまで取り合えず動かすところまで一気通貫で説明したいと思います。

そのため、記事が長くなるかと思いますがよろしくお願いします。

## この記事で実現すること

- HoloLens,iOS,AndroidでAzure Spatial Anchorのチュートリアルサンプルをビルドする
- iOSとAndroidでAzure Spatial Anchorによる位置固定を体験する

実際にAndroidで動かしてみたデモ動画がこちら。
Find Anchorすると、事前に固定した位置にオブジェクトが戻ることが確認できます。(空間に対してオブジェクトを固定することができる)

https://youtu.be/xjDg0AYUPYo

## この記事で実現できなかったこと

- HoloLensによる位置固定
- HoloLens,iOS,Android間での位置共有

こちらは次回以降の記事でのチャレンジにしたいと思います。

# 読者対象

- Unityを使ったHoloLens,iOS,Android開発はやったことがある
- Azureを使うのは初めて
- Azure Spatial Anchorsを使うのも初めて

# チュートリアルの前提条件 (Learnページから引用)

https://docs.microsoft.com/ja-jp/learn/modules/azure-spatial-anchors-tutorials/

- [正しいツール](https://docs.microsoft.com/ja-jp/windows/mixed-reality/develop/install-the-tools)が構成された Windows 10 PC
- Windows 10 SDK 10.0.18362.0 以降
- 開発用に構成された HoloLens 2 デバイス
- Unity 2020.3.X または 2019.4.X がインストールされ、ユニバーサル Windows プラットフォーム ビルド サポート モジュールが追加された Unity Hub
- [Unity モジュールで Mixed Reality プロジェクトを設定する](https://docs.microsoft.com/ja-jp/learn/modules/mixed-reality-toolkit-project-unity/)
    - **こちらもこの記事で手順を説明します。**
- [Mixed Reality Feature Tool](https://www.microsoft.com/en-us/download/details.aspx?id=102778)
- Unity のインターフェイス、シーンの作成、パッケージのインポート、シーンへの GameObjects の追加に関する基本的な知識
- 「[Spatial Anchors リソースを作成する](https://docs.microsoft.com/ja-jp/azure/spatial-anchors/quickstarts/get-started-unity-hololens?tabs=azure-portal#create-a-spatial-anchors-resource)」セクション (クイック スタート:Azure Spatial Anchors を使用する Unity HoloLens アプリを作成する チュートリアルにあります) を完了します。
    - **こちらもこの記事で手順を説明します。**

# 著者の環境

|項目|バージョン|
|---|---|
|Windowsバージョン|Windows10 Home|
|Visual Studio 2019|-|
|Unity|2020.3.18f1|
|HoloLens2|-|
|Mixed Reality Feature Tool|1.0.2111.0-Preview|

|UnityのPlugin|バージョン|
|---|---|
|Mixed Reality Toolkit Foundation|2.7.3|
|Mixed Reality OpenXR|1.3.0|
|Azure Spatial Anchors SDK|2.12.0|
|AR Foundation|4.1.7|
|ARCore XR|4.1.9|
|ARkit XR|4.1.9|

# この記事による手順の目次

- UnityでHoloLensビルド用のMRTKとOpenXRをセットアップする
- AzureでSpatial Anchors リソースを作成する
- Azure Spatial Anchor向けにUnityの設定
- モバイル(iOS,Android)用の設定
- Android向けビルドの設定
- iOS向けビルドの設定
- Azure Spatial Anchorsの試し方

# UnityでHoloLensビルド用のMRTKとOpenXRをセットアップする

主にUnity上での作業になります。
MRTKのimportのやり方は複数ありますが、この記事ではドキュメントに沿ってMixed Reality Feature Toolを使った手法で行っています。

## 手順

Unityプロジェクトを開く

- Versionを2020.3.xxを選択
    - 私は2020.3.18f1
- 「AzureSpatialAnchorsSample」と名前を付けてプロジェクトを作成

![](/images/hololens-2022-2/2022-02-11-12-19-30.png)

Build Settingsから **[Universal Windows Platform]** にSwitch Platform

Build Settingsを開き以下のように設定する

| 項目                     | 選択すべき設定   |
| ------------------------ | ---------------- |
| Target Device            | **HoloLens**     |
| Architecture             | **ARM64**        |
| Build Type               | D3D Project      |
| Target SDK Version       | Latest installed |
| Minimum Platform Version | 10.0.10230.0     |
| Visual Studio Version    | Latest installed |
| Build and Run on         | Local Machine    |
| Build configuration      | Release          |


![](/images/hololens-2022-2/2022-02-12-21-12-46.png)

TextMeshProの重要なリソースをインポートする

- [Window] > [TextMeshPro] > [Import TMP Essential Resources] を選択

![](/images/hololens-2022-2/2022-02-11-13-43-20.png)

- Mixed Reality Toolkit のインポートと Unity プロジェクトの構成

この記事では[Mixed Reality Feature Tool](https://www.microsoft.com/en-us/download/details.aspx?id=102778)から構成します。ダウンロードしてexeファイルを開く。私のバージョンは1.0.2111.0-Previewでした。

ここから[Start]をクリック

![](/images/hololens-2022-2/2022-02-11-13-45-31.png)

:::message
ProjectPathを設定は以下のフォルダーを含むディレクトリを選択
- Assets
- Packages
- ProjectSettings
:::

できたら **[Discover Features]** を選択。

![](/images/hololens-2022-2/2022-02-11-13-48-24.png)

Mixed Reality Toolkitの

- Mixed Reality Toolkit Foundation 2.7.3
- Mixed Reality Toolkit Examples 2.7.3 (Option)
- Mixed Reality Toolkit Standard Assets 2.7.3 (Option)

Platform Supportの

- Mixed Reality OpenXR Plugin 1.3.0

を選択して、[Get Features]を選択。
ExamplesとStandard Assetsは必須でないかもしれないが、不安なので追加。

![](/images/hololens-2022-2/2022-02-12-16-33-44.png)

そのまま[Approve]を選択。
importが始まります。ここでUnityに戻ります。

ポップアップがでたらYesを選択。

![](/images/hololens-2022-2/2022-02-12-16-03-16.png)

[MRTK Project Configurator]のWindowが現れる。

:::message
[MRTK Project Configurator]のWindowが出ない場合は
Unityメニューから[Mixed Reality] > [Toolkit] > [Utilities] > [Configure Project for MRTK]を選択
:::


今回は[Unity OpenXR Plugin]を選択。

![](/images/hololens-2022-2/2022-02-12-16-00-50.png)

**[Project Settings]** > **[XR Plug-in Management]** から
- **[Windows Platform]タブ** > **[Plug-in Providers]** > **[OpenXR]** にチェックを入れる。
- **[Microsoft HoloLens feature group]** にチェックを入れる。

![](/images/hololens-2022-2/2022-02-12-16-38-56.png)

[Project Settings]の[XR Plug-in Management]>[OpenXR]を開き
- Depth Submission Modeを **[Depth 16 Bit]** を選択。
- Interaction Profilesで **[Microsoft Hand Interaction Profile]** を選択。

![](/images/hololens-2022-2/2022-02-12-16-41-58.png)

MRTK Project Configuratorを開き、[Apply Settings]をクリックした後に、[Next]をクリック。
![](/images/hololens-2022-2/2022-02-12-16-44-31.png)

[Apply]をクリック。
![](/images/hololens-2022-2/2022-02-12-16-45-44.png)

Project SettingsのOpenXRを開いて警告マークがあったらクリックして、Fix Allを選択。
![](/images/hololens-2022-2/2022-02-12-19-06-58.png)

UnityのEditorに戻る。
「AzureSpatialAnchors」という名前のSceneを作る。
ここからHoloLens用にSceneをセットアップする。

[Mixed Reality]>[Toolkit]>[Add to Scene and Configure...]を選択。
![](/images/hololens-2022-2/2022-02-12-19-10-15.png)

MRTK構成プロファイルをDefaultHoloLens2ConfigurationProfileにする。

- ヒエラルキー上のMixedReality Toolkitを選択
- コンポーネントのMixedRealityToolKitを見て[DefaultHoloLens2ConfigurationProfile]を選択
    - Cloneを選択
- Clone Profileのウィンドウ
    - ProfileNameを入れる (今回は「AzureSpatialAnchorsConfigurationProfile」を入力)
    - Cloneを選択

![](/images/hololens-2022-2/2022-02-12-19-14-45.png)

空間認識メッシュの表示オプションをOcclusionに変更する。

- MixedRealityToolKitコンポーネントの[Spatial Awareness]を選択
    - Enable Spatial Awareness Systemにチェックを入れる
    - Cloneを選択
- Clone Profileのウィンドウ
    - ProfileNameを入れる(今回は「AzureSpatialAnchorsSpatialAwarenessSystemProfile」を入力)
    - Cloneを選択

![](/images/hololens-2022-2/2022-02-12-19-20-03.png)

- OpenXR Spatial Mesh Observerの▼を選択して開く
    - Cloneをクリック
- Clone Profileのウィンドウ
    - ProfileNameを入れる(今回は「AzureSpatialAnchorsSpatialAwarenessMeshObserverProfile」を入力)
    - Cloneを選択

![](/images/hololens-2022-2/2022-02-12-19-25-07.png)

Display Optionで「Occlusion」を選択する。

![](/images/hololens-2022-2/2022-02-12-19-31-15.png)

BuildSettingを開く

- 現在のSceneをScenes in Buildに追加する
- Player Settingsの[Publishing Settings]>[Packaging]>[Package name]を入力する
    - 今回は「AzureAnchorSample」を入力

![](/images/hololens-2022-2/2022-02-12-19-39-18.png)

これでMRTKとOpenXRの設定は準備OKです！



# AzureでSpatial Anchorsリソースを作成する

https://docs.microsoft.com/ja-jp/azure/spatial-anchors/quickstarts/get-started-unity-hololens?tabs=azure-portal#create-a-spatial-anchors-resource

この中身を見ながら進めていきます。今回、GUIで操作できる(一般の人に優しい)Azureポータルを使用するフローを行います。

## 手順

- [Azureポータル](https://portal.azure.com/)にアクセス
- **[リソースの作成]** を選択
- 検索ボックスを使用して **「Spatial Anchors」** を検索
- **[Spatial Anchors]** を選択して **[作成]** を選択

Create Spatial Anchorsのページに移動します。
- サブスクリプション
    - [Pay-As-You-Go] or [従量課金]
        - 今回私は **[Pay-As-You-Go]** を選択
    - リソースグループ
        - 「myResourceGroup」と名前を付け、 [OK] を選択します。
- リソースを配置する場所 (リージョン)を選択 (私が行った選択を共有)
    - 名前は「Tokyo」を入力
        - もっとわかりやすい名前がおすすめです「MyAppSpatialAnchors」など
    - リージョンは「Korea Central」を選択 (Japan Eastがなかった)
- **[確認と作成]** を選択！

![](/images/hololens-2022-2/2022-02-11-12-49-21.png)

さらに **[作成]** を選択。

ここまでいくとデプロイが始まります。完了画面が表れます。

![](/images/hololens-2022-2/2022-02-11-12-52-54.png)

**[リソースに移動]** を選択

![](/images/hololens-2022-2/2022-02-11-12-59-04.png)

以下の情報をコピーしてメモ帳などに控えておく (後で使用します)
- AccountID
- Account Domain
- Access KeysのPrimary key


::: message alert
Primary keyなどは他人に公開しないようにする
:::

![](/images/hololens-2022-2/2022-02-11-13-02-51.png)



# Azure Spatial Anchor向けにUnityの設定

https://docs.microsoft.com/ja-jp/learn/modules/azure-spatial-anchors-tutorials/3-exercise-get-started-with-azure-spatial-anchors

こちらに戻って進めます。

## チュートリアルのアセットをインポートする。

以下のパッケージがインストールされていることを確認

- Mixed Reality OpenXR Plugin 1.3.1
- Windows XR Plugin 4.5.0
- ARCore XR Plugin 4.1.9
- ARKit XR Plugin 4.1.9
- AR Foundation 4.1.7

## ASA(Azure Spatial Anchors)パッケージのダウンロード

Microsoft Mixed Reality Feature Tool.exeを開く。

- Azure Spatial Anchors SDK Core 2.12.0
- Azure Spatial Anchors for Windows 2.12.0

を選択。[Get Features]をクリック。[Import],[Approve]を選択。

![](/images/hololens-2022-2/2022-02-12-22-32-22.png)

[ProjectSettings]>[Player]>[Publishing Settings]>[Capabilities]にて、以下にチェックが入っていることを確認する。

- SpatialPerception
- InternetClient
- **PrivateNetworkClientServer**

![](/images/hololens-2022-2/2022-02-12-22-36-54.png)



[こちらのページ](https://github.com/microsoft/MixedRealityLearning/releases)から、チュートリアル用のunitypackageを2つダウンロードしimportする。
今回は

- [MRTK.HoloLens2.Unity.Tutorials.Assets.GettingStarted.2.7.2.unitypackage](https://github.com/microsoft/MixedRealityLearning/releases/download/getting-started-v2.7.2/MRTK.HoloLens2.Unity.Tutorials.Assets.GettingStarted.2.7.2.unitypackage)
- [MRTK.HoloLens2.Unity.Tutorials.Assets.AzureSpatialAnchors.2.7.2.unitypackage](https://github.com/microsoft/MixedRealityLearning/releases/download/azure-spatial-anchors-v2.7.2/MRTK.HoloLens2.Unity.Tutorials.Assets.AzureSpatialAnchors.2.7.2.unitypackage)

のバージョンを選択。↑をクリックするとダウンロードできます。

## シーンの準備 (チュートリアル)

プロジェクトウィンドウにて[Assets]> [MRTK.Tutorials.AzureSpatialAnchors] > [Prefabs]フォルダーの以下のPrefabをHierarchyウィンドウにドラッグで追加します。

- ButtonParent Prefab
- DebugWindow Prefab
- Instructions Prefab
- ParentAnchor Prefab

![](/images/hololens-2022-2/2022-02-12-22-50-25.png)

Hieraruchyビューの[MixedReality Toolkit]を選択。
Inspectorビューの[Add Component]から

- [AR Anchor Manager]
- [DisableDiagnosticsSystem]

を追加。

![](/images/hololens-2022-2/2022-02-12-23-04-20.png)

Hieraruchyビューで[ButtonParent]オブジェクトを展開し、[StartAzureSession]という名前の子オブジェクトを選択し、Inspectorビューで、Button Config HelperコンポーネントのOnClick()イベントを次のように構成します。

- ParentAnchorオブジェクトを[None (Object)]フィールドに割り当てます。
- No Functionのドロップダウンから、[AnchorModuleScript] > [StartAzureSession()]の順に選択し、この関数をイベントがトリガーされたときに実行するアクションとして設定します。

![](/images/hololens-2022-2/2022-02-12-23-09-13.png)

同様な設定を、その他のボタンに対しても行います。

- [StopAzureSessionオブジェクト]
    - ParentAnchor オブジェクトを [None (Object)] フィールドに割り当てます
    - No Functionのドロップダウンから、[AnchorModuleScript] > [StopAzureSession()]の順に選択
- [CreateAzureAnchorオブジェクト]
    - ParentAnchor オブジェクトを [None (Object)] フィールドに割り当てます
    - No Functionのドロップダウンから、[AnchorModuleScript] > [CreateAzureAnchor()]の順に選択
    - **ParentAnchorオブジェクト** を空の [None (Object)] フィールドに割り当てる。
- [RemoveLocalAnchorオブジェクト]
    - ParentAnchor オブジェクトを [None (Object)] フィールドに割り当てます
    - No Functionのドロップダウンから、[AnchorModuleScript] > [RemoveLocalAnchor()]の順に選択
    - **ParentAnchorオブジェクト** を空の [None (Object)] フィールドに割り当てる。
- [FindAzureAnchorオブジェクト]
    - ParentAnchor オブジェクトを [None (Object)] フィールドに割り当てます
    - No Functionのドロップダウンから、[AnchorModuleScript] > [FindAzureAnchor()]の順に選択
- [DeleteAzureAnchorオブジェクト]
    - ParentAnchor オブジェクトを [None (Object)] フィールドに割り当てます
    - No Functionのドロップダウンから、[AnchorModuleScript] > [DeleteAzureAnchor()]の順に選択

## Azureリソースに接続する

[ParentAnchor]の[Spatial Anchor Manager]の

- Spatial Anchors Account id
- Spatial Anchors Account Key
- Spatial Anchors Domain

に、前半でコピーした文字列を代入。

![](/images/hololens-2022-2/2022-02-12-23-31-10.png)


この状態でHoloLensにビルド！

するとエラーが

```
Reference rewriter: Error: type `System.Web.HttpUtility` doesn't exist in target framework. It is referenced from RestSharp.dll at System.String RestSharp.Extensions.StringExtensions::UrlDecode(System.String).
UnityEngine.Debug:LogError (object)
PostProcessWinRT:RunReferenceRewriter () (at C:/buildslave/unity/build/PlatformDependent/MetroPlayer/Extensions/Managed/PostProcessWinRT.cs:1195)
PostProcessWinRT:Process () (at C:/buildslave/unity/build/PlatformDependent/MetroPlayer/Extensions/Managed/PostProcessWinRT.cs:203)
UnityEngine.GUIUtility:ProcessEvent (int,intptr,bool&)

```

[こちらの記事](https://github.com/microsoft/MixedRealityToolkit-Unity/issues/8839)を参考に修正。

Projectブラウザ

- [MRTK.Tutorials.AzureSpatialAnchors\Plugins\RestSharp.dll]を選択

Inspectorビューを開く

- [Platform settings]>[SDK]>[UWP]を選択
- Don't processにチェックを入れる
- [Select platforms for plugin]
    - [Any Platform]の**チェックを外す**
    - 下にある全てのInclude Platformsにチェックを入れる。
- [Apply]をクリック

![](/images/hololens-2022-2/2022-02-12-23-48-24.png)

## 体験を固定する

Hierarchyビューで[ParentAnchor]オブジェクトを選択し、Transformを以下のように設定します

- Scale (1.1,0.1,1.1) 

Projectブラウザ

- [Assets]> [MRTK.Tutorials.GettingStarted] > [Prefabs] > [Rover] > [RoverExplorer_Complete]Prefabをシーンに追加する。
- [ParentAnchor]オブジェクトの子供に[RoverExplorer_Complete]オブジェクトを置く。

![](/images/hololens-2022-2/2022-02-13-00-51-22.png)

## シーンの準備

Hierarchyビューで[ButtonParent]オブジェクトを展開し、非アクティブになっている子オブジェクトを選択し、アクティブにする。

![](/images/hololens-2022-2/2022-02-13-01-06-50.png)

[ButtonParent]オブジェクトを選択し、Inspectorビューにて[GridObjectCollection]コンポーネントを見つけ、[Update Collection]ボタンをクリックする。

すると、[ButtonParent]オブジェクトの子オブジェクトが整列します。

![](/images/hololens-2022-2/2022-02-13-01-09-11.png)

## アプリ セッション間で Azure Spatial Anchors を保持する

> HoloLens のローカル ディスクとの間で、Azure Anchor ID を保存および取得する方法について学習します。 これにより、異なるアプリ セッション間で同じアンカー ID の Azure に対してクエリを実行できます。 固定されたホログラムを前のアプリ セッションと同じ場所に配置できるようになります。

Hierarchyビューで[ButtonParent]オブジェクトを展開し、[SaveAzureAnchorIdToDisk]と[GetAzureAnchorIdFromDisk]という名前の2つのボタンを探します。

## ASA フィードバック パネルを設定する

- Hierarchyビューで[Instructions]>[TextContent]を右クリック
- [3DObject]>[Text - TextMeshPro]を選択して作成。

![](/images/hololens-2022-2/2022-02-13-01-21-57.png)

新しく作成した(TMP)オブジェクトを選択し

- 名前を「Feedback」に変更
- [Rect Transform]コンポーネントの [Pos Y]を`-0.24`に変更します。
- [Rect Transform]コンポーネントの [Width] を `0.555` に変更します。
- [Rect Transform]コンポーネントの [Height] を `0.1` に変更します。
- [TextMeshPro - Text] コンポーネントの [Font Style] を [Bold] に変更します。
- [TextMeshPro - Text] コンポーネントの [Font Size] を `0.17` に変更します。
- [TextMeshPro - Text] コンポーネントの [Alignment] を中央揃えに変更します。

![](/images/hololens-2022-2/2022-02-13-01-25-45.png)

[Feedback]オブジェクトを選択した状態で

- AddComponentで[Anchor Feedback Script (Script)]を選択
- [Anchor Feedback Script]コンポーネントのFeedbackTextフィールドに、Feedbackオブジェクトを割り当てる。

![](/images/hololens-2022-2/2022-02-13-01-31-11.png)

# モバイル(iOS,Android)共通の設定

ここまではHoloLens用の設定でした。
この章から、モバイル(iOS,Android)共通の設定の設定を説明します。後の章ではiOS,Android固有の設定の説明をします。

## 手順

Hierarchyビューで[MixedRealityToolkit]オブジェクトを選択する。次にInspectorビューで[Camera]タブを選択。

- 現在のProfileをCloneして「AzureSpatialAnchors_ARCameraProfile」等と名前を付ける。
- [Camera Settings Providers]を展開して、[XR SDK Windows Mixed Reality Camera Settings]を含むすべての[CameraSettings]を「-」ボタンをクリックして削除する。

![](/images/hololens-2022-2/2022-02-13-00-14-18.png)

続いて、
- [Add Camera Settings Provider]を選択
- [Type]ドロップダウンから[Microsoft.MixedReality.Toolkit.Experimental.UnityAR]>[UnityARCameraSettings]を選択

![](/images/hololens-2022-2/2022-02-13-00-15-34.png)

Unityメニューから[Mixed Reality]>[Toolkit]>[Utilities]>[UnityAR]>[Update Scripting Defines]を選択

![](/images/hololens-2022-2/2022-02-13-00-17-52.png)

Mixrosoft Mixed Reality Feature Toolを立ち上げ

- Azure Spatial Anchors SDK for Android 2.12.0
- Azure Spatial Anchors SDK for iOS 2.12.0

を選択し[Get Features]を選択。その後[Import]、[Approve]を選択。

![](/images/hololens-2022-2/2022-02-13-02-16-29.png)

# Android向けビルドの設定

## 手順
Unityメニューで[File]>[Build Settings]を選択して、プラットフォームを[Android]に変更する。

Unityメニューで[Mixed Reality]>[Toolkit]>[Utilities]>[Configure Project for MRTK]を選択

全てのオプションを選択し、[Apply]を選択。(この画面が出なかった場合はSkip This Stepを選択)

![](/images/hololens-2022-2/2022-02-13-02-00-00.png)

- [ProjectSettings]>[Player]を選択
- [Other Settings]>[Graphics APIs]の[Vulkan]を選択し「-」をクリックし削除する。

![](/images/hololens-2022-2/2022-02-13-02-04-46.png)

- [Project Settings] > [XR Plug-in Management]を選択
- [Windows Platform]のタブを選択
- OpenXRでの警告マークをクリック
- [Fix All]をクリック

![](/images/hololens-2022-2/2022-02-13-02-08-43.png)

- [Project Settings] > [XR Plug-in Management]を選択
- [Android Platform]のタブを選択
- [ARCore]にチェックを入れる

![](/images/hololens-2022-2/2022-02-13-02-11-20.png)

AndroidのMinimum API Levelを24に設定する。

- [Project Settings]>[Player]>[Public Settings]>[Identification]>[Minimum API Level]を[Android7.0 (API Level24)]に設定する。

![](/images/hololens-2022-2/2022-02-13-02-27-50.png)

mainTemplate.gradle ファイルを構成する

- [Project Settings]>[Player]>[Androidアイコン]を選択
- [Publishing Settings]>[Build]セクション>[Custom Main Gradle Template]にチェックを入れる。するとGradle Templateファイルが生成される。
- Assets/Plugins/Android/mainTemplate.gradleファイルをテキストエディターで開く
- `dependencies`セクションに、次の依存関係を貼り付ける。

```gradle:mainTemplate.gradle
implementation('com.squareup.okhttp3:okhttp:[3.11.0]')
implementation('com.microsoft.appcenter:appcenter-analytics:[1.10.0]')
```

すべて完了すると、`dependencies`セクションは次のようになります。

```gradle:mainTemplate.gradle
dependencies {
    implementation fileTree(dir: 'libs', include: ['*.jar'])
    implementation('com.squareup.okhttp3:okhttp:[3.11.0]')
    implementation('com.microsoft.appcenter:appcenter-analytics:[1.10.0]')
**DEPS**}
```

![](/images/hololens-2022-2/2022-02-13-03-15-55.png)

ここまで来たら、PCとAndroidをUSBでつないで **Build And Run**

## 参考記事

https://docs.microsoft.com/ja-jp/azure/spatial-anchors/how-tos/setup-unity-project?tabs=xr-plugin-framework%2Cunity-2020%2Cunity-package-web-ui


# iOS向けビルドの設定

## 開発環境

iOSアプリはMacでないと開発できないので、開発機WindowsからMacに切り替える。

## 手順


Unityメニューで[File]>[Build Settings]を選択して、プラットフォームを[iOS]に変更する。

- [Project Settings] > [XR Plug-in Management]を選択
- [iOS Platform]のタブを選択
- [ARKit]に**チェックを入れる**
![](/images/hololens-2022-2/2022-02-13-03-28-34.png)

- [Project Settings] > [Player]を選択
- [Other Settings]> [Optimization]セクション > [Strip Engine Code]の**チェックを外す**

![](/images/hololens-2022-2/2022-02-13-03-33-56.png)

- [Camera Usage Description]を空欄にしないようにする
  - 例えば「Use Camera」と入力

![](/images/hololens-2022-2/2022-02-13-03-44-04.png)

[Assets/MRTK.Tutorials.AzureSpatialAnchors/Plugins/RestSharp]を選択。

- [iOS]にチェックを入れる
- [ARKit]にチェックを入れる
- [Apply]をクリック

![](/images/hololens-2022-2/2022-02-13-04-11-19.png)

ここまで来たらXCode向けにBuild

# Azure Spatial Anchorsの試し方

https://docs.microsoft.com/ja-jp/learn/modules/azure-spatial-anchors-tutorials/3-exercise-get-started-with-azure-spatial-anchors

こちらの記事か、ビルドしたアプリの指示に従って動作させます。

1. Cubeを別の場所に移動します
1. Start Azure Sessionを押す
1. Create Azure Anchorを押す (Cubeの場所にAnchorを作成します)
1. Stop Azure Sessionを押す
1. Remove Local Anchorを押す (これにより、ユーザーはCubeを移動できるようになる)
1. Cubeを別の場所に移動させる
1. Start Azure Sessionを押す
1. Find Azure Anchorを押す ** (これで3.の位置にCubeが瞬間移動すれば成功) ** 
1. Delete Azure Anchorを押す
1. Stop Azure Sessionを押す

すると、iOSとAndroidでは想定通りに動作します。

https://youtu.be/xjDg0AYUPYo

# 今後の課題

一番やりたいのは、こちらのチュートリアルの挙動です。

https://docs.microsoft.com/ja-jp/learn/modules/azure-spatial-anchors-tutorials/5-exercise-save-retrieve-share-azure-spatial-anchors

つまりこれです。

![](https://docs.microsoft.com/ja-jp/azure/spatial-anchors/media/cross-platform.png)

チュートリアルの下の方に書かれていることを実行しようとしました。

> 更新されたアプリを 2 つの HoloLens デバイスにビルドすると、Azure Anchor ID を共有することで、空間的な位置合わせを実現できるようになります。 これをテストするには、次の手順を実行します。

実際はHoloLensの2つ目のデバイスを持っていないため、iPhoneで代用しています。次のような処理になります。

1. HoloLensで次のようにします。Rover Explorer を目的の場所に移動します。
2. HoloLensで: Azure セッションを開始します。
3. HoloLensで: Azure アンカーを作成します (Rover Explorer の場所にアンカーを作成します)。
4. HoloLensで: Azure アンカー ID をネットワークに共有します。
5. iPhone で次のようにします。アプリを起動します。
6. iPhone で次のようにします。ネットワークから共有アンカー ID を取得します (HoloLensから共有されたアンカーIDを取得します)。
7. iPhoneで: Azure セッションを開始します。
8. iPhoneで: Azure アンカーを検索します (手順 3 の場所に Rover Explorer を配置します)。

ここで6.のネットワークから共有アンカー取得ができない...というところで詰まっています。

4の処理のコードを見ると、グローバルIPにAnchorIDをアップロードする処理が書かれているものの、実行すると該当のIPアドレス先のファイルにはAnchorIDが記されていない状態でした。

いずれにしても、AnchorIDを誰にでも見れる場所にアップロードするのは良くないと思うので、次回はAnchorIDを安全に共有する方法も含めて調査します。

また、HoloLensではiOS,Androidで成功したような「Find Azure Anchor」時に元の位置に戻らない現象についても、引き続き調査します。

```csharp:AnchorModuleScript.cs
  public void ShareAzureAnchorIdToNetwork()
    {
        Debug.Log("\nAnchorModuleScript.ShareAzureAnchorID()");

        string filename = "SharedAzureAnchorID." + publicSharingPin;
        string path = Application.persistentDataPath;

#if WINDOWS_UWP
        StorageFolder storageFolder = ApplicationData.Current.LocalFolder;
        path = storageFolder.Path + "/";           
#endif

        string filePath = Path.Combine(path, filename);
        File.WriteAllText(filePath, currentAzureAnchorID);

        Debug.Log($"Current Azure anchor ID '{currentAzureAnchorID}' successfully saved to path '{filePath}'");

        try
        {
            var client = new RestClient("http://167.99.111.15:8090");

            Debug.Log($"Connecting to network client '{client}'... please wait...");

            var request = new RestRequest("/uploadFile.php", Method.POST);
            request.AddHeader("Accept", "application/json");
            request.AddHeader("Content-Type", "multipart/form-data");
            request.AddFile("the_file", filePath);
            request.AddParameter("replace_file", 1);  // Only needed if you want to upload a static file

            var httpResponse = client.Execute(request);

            Debug.Log("Uploading file... please wait...");

            string json = httpResponse.Content.ToString();
        }
        catch (Exception ex)
        {
            Debug.Log(string.Format("Exception: {0}", ex.Message));
            throw;
        }

        Debug.Log($"Current Azure anchor ID '{currentAzureAnchorID}' shared successfully");
    }
```