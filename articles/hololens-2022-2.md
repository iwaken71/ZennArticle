---
title: "Microsoft Learn「Azure Spatial Anchors を使用して実世界のオブジェクトを固定する」をやってみる"
emoji: "🔥"
type: "tech" # tech: 技術記事 / idea: アイデア
topics: ["Unity","HoloLens","Azure"]
published: false
---
# 概要
Microsoft Learnで「Azure Spatial Anchors を使用して実世界のオブジェクトを固定する」を実践して困ったことや気づいたことを記事にしたいと思います。
https://docs.microsoft.com/ja-jp/learn/modules/azure-spatial-anchors-tutorials/

# 読者対象

- UnityやHoloLens開発はやったことがある
- Azureを使うのは初めて
- Azure Spatial Anchorsを使うのも初めて

# 前提条件 (Learnページから引用)

- [正しいツール](https://docs.microsoft.com/ja-jp/windows/mixed-reality/develop/install-the-tools)が構成された Windows 10 PC
- Windows 10 SDK 10.0.18362.0 以降
- 開発用に構成された HoloLens 2 デバイス
- Unity 2020.3.X または 2019.4.X がインストールされ、ユニバーサル Windows プラットフォーム ビルド サポート モジュールが追加された Unity Hub
    - 今回私は2020.3.18f1を使用します。
- [Unity モジュールで Mixed Reality プロジェクトを設定する](https://docs.microsoft.com/ja-jp/learn/modules/mixed-reality-toolkit-project-unity/)
    - HoloLensの基本的開発をやったことある人はスルーしてOKです
- [Mixed Reality Feature Tool](https://www.microsoft.com/en-us/download/details.aspx?id=102778)
- Unity のインターフェイス、シーンの作成、パッケージのインポート、シーンへの GameObjects の追加に関する基本的な知識
-「[Spatial Anchors リソースを作成する](https://docs.microsoft.com/ja-jp/azure/spatial-anchors/quickstarts/get-started-unity-hololens?tabs=azure-portal#create-a-spatial-anchors-resource)」セクション (クイック スタート:Azure Spatial Anchors を使用する Unity HoloLens アプリを作成する チュートリアルにあります) を完了します。
    - こちら終わっていない...! まずはこれをクリアしてからこのLearnを進めていきましょう。


# 「Spatial Anchors リソースを作成する」をクリアする

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

以下の情報をコピー
- AccountID
- Account Domain
- Access KeysのPrimary key

![](/images/hololens-2022-2/2022-02-11-13-02-51.png)

# Azure Spatial Anchorsの説明からの学びの整理

## Azure Spatial Anchors の概要

https://docs.microsoft.com/ja-jp/learn/modules/azure-spatial-anchors-tutorials/2-get-started-with-azure-spatial-anchors

> Azure Spatial Anchors は、HoloLens、ARKit を使用した iOS デバイス、および ARCore を使用した Android デバイス向けの空間認識 Mixed Reality アプリケーションを作成するのに必要なツールを開発者に提供します。

HoloLensだけでなく、iOS、Androidにも対応している！

> Azure Spatial Anchors のユース ケースには、次のようなものがあります。
> - World-Tracking:
> - Internet of Things(IoT):

自己位置推定的な話と、現実のモノとインターネットを通じて連携できますよという話があります。

> **AR Foundation**
Unity 内の AR Foundation を使用すると、拡張現実システムを複数のプラットフォームで操作できます。 このパッケージは Unity 開発者にインターフェイスを提供しますが、AR 機能は含まれていません。 ターゲット デバイスで、Unity の公式にサポートされているターゲット プラットフォーム用の個別のパッケージも必要になります。
> - Android 上の ARCore XR プラグイン
> - iOS 上の ARKit XR プラグイン
> - Magic Leap 上の Magic Leap XR プラグイン
> - HoloLens 上の Windows XR プラグイン

**「ARFoundation + ○○Plugin」** という構成なんですね。

> **AR Anchor Manager script**

デバイスに追跡させたい空間上の点を **アンカー(Anchor)** と呼ぶ。
それぞれのAnchorに対してAnchorManagerはGameObjectを生成する。
ARAnchorManagerの [Anchor Prefab]フィールドはコンテンツのためのものではなく、代わりにARFoundationがAnchorを表すGameObjectを新たに作成します。

ちょっとわからないので、あとで手を動かしながら理解しよう。


# Unity手順

## MRTKの準備

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

- [Window] > [extMeshPro] > [Import TMP Essential Resources] を選択

![](/images/hololens-2022-2/2022-02-11-13-43-20.png)

- Mixed Reality Toolkit のインポートと Unity プロジェクトの構成

この記事では[Mixed Reality Feature Tool](https://www.microsoft.com/en-us/download/details.aspx?id=102778)から構成します。ダウンロードしてexeファイルを開く。私のバージョンは1.0.2111.0-Previewでした。

ここから[Start]をクリック

![](/images/hololens-2022-2/2022-02-11-13-45-31.png)

ProjectPathを設定。以下のフォルダーを含むディレクトリを選択
- Assets
- Packages
- ProjectSettings

できたら[Discover Features]を選択。

![](/images/hololens-2022-2/2022-02-11-13-48-24.png)

Mixed Reality Toolkitの

- Mixed Reality Toolkit Foundation 2.7.3
- Mixed Reality Toolkit Examples 2.7.3 (Option)
- Mixed Reality Toolkit Standard Assets 2.7.3 (Option)

Platform Supportの

- Miced Reality OpenXR Plugin 1.3.0

を選択して、[Get Features]を選択。
ExamplesとStandard Assetsは必須でないかもしれないが、不安なので追加。

![](/images/hololens-2022-2/2022-02-11-13-54-31.png)
![](/images/hololens-2022-2/2022-02-12-16-33-44.png)

そのまま[Approve]を選択。
importが始まります。ここでUnityに戻ります。

ポップアップがでたらYesを選択。

![](/images/hololens-2022-2/2022-02-12-16-03-16.png)

[MRTK Project Configurator]のWindowが現れる。出ない場合は

- [Mixed Reality] > [Toolkit] > [Utilities] > [Configure Project for MRTK]を選択

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

# Azure Spatial Anchor向けにUnityの設定

Unityメニューの[Windows] > [Package Manager]を選択。

ARFoundationの4.1.7バージョンがインストールされていることを確認します。[Packages: Unity Registry]を選択して確認。

![](/images/hololens-2022-2/2022-02-12-22-19-08.png)

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

https://github.com/microsoft/MixedRealityLearning/releases

から、チュートリアル用のunitypackageを2つダウンロードしimportする。
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

# モバイル(iOS,Android)用の設定

Hierarchyビューで[MixedRealityToolkit]オブジェクトを選択する。次にInspectorビューで[Camera]タブを選択。

- 現在のProfileをCloneして「AzureSpatialAnchors_ARCameraProfile」等と名前を付ける。
- [Camera Settings Providers]を展開して、[XR SDK Windows Mixed Reality Camera Settings]の横にある「-」ボタンをクリックして削除する。

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

# Androidの設定

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

# iOS

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

# この記事で伝えたいこと　←★重要★
# 解決したい課題　←★重要★
# 課題の原因
# 課題を解決する技術、手法