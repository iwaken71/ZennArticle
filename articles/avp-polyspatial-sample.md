---
title: "Let's Apple Vision Pro! Sampleから学ぶPolySpatialのXR機能紹介"
emoji: "👓"
type: "tech" # tech: 技術記事 / idea: アイデア
topics: ["Unity","AppleVisionPro","visionOS"]
published: true
---

こんにちは、サイバーエージェントのXR研究所の[イワケン](https://twitter.com/iwaken71)です。

「社内外にXRを啓蒙し、事業のタネを作る」をミッションにXRの体験会、勉強会、プロトタイピング、開発プロジェクトなどを行っています。

この記事では、UnityのPolySpatialのSampleからvisionOS向けのXR機能の紹介を行います。(社内visionOS勉強会で発表した内容をZennに記事化しました)

実装方法については概要のみの紹介とさせていただきます。
Apple Vision Proでの実機での動作も共有します。

![](/images/gif/mixedreality.gif)
*Mixed RealityのSample*

# 開発環境

私が検証した開発閑居はこちらです。

|ツール|バージョン|
|---|---|
|Apple M2,Sonoma|14.4.1|
|Unity|2022.3.18f1|
|PolySpatial|1.1.6|
|Xcode|15.3|
|visionOS|1.2|

ドキュメントは[こちら](https://docs.unity3d.com/Packages/com.unity.polyspatial.visionos@1.1/manual/Requirements.html)。PolySpatial visionOS 1.1.6の場合

- An Apple Silicon Mac
- Unity2022.3.18以上
- Xcode 15.2以上
- visionOS 1.0以上

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

Package Managerを通じて、もしくはmanifest.jsonに直接書き込む形で

```json:manifest.json
{
  "dependencies": {
    "com.unity.polyspatial": "1.1.6",
    "com.unity.polyspatial.visionos": "1.1.6",
    "com.unity.polyspatial.xr": "1.1.6",
    ...
  }
}
```
を追加します。するとPackage ManagerにPolySpatial系のパッケージが追加されます。


![](/images/avp/2024-05-07-13-13-28.png)

PolySpatialのSampleを選ぶとSampleをimportできます！

:::message
PolySpatialを使用できるのは、Unity Pro,Enterpriseのライセンスのみになります。
:::


## SampleのScene一覧

- **Balloon Gallery (紹介)**
- CharacterWalker
- **ImageTracking (紹介)**
- **Manipulation (紹介)**
- Meshing
- **MixedReality (紹介)**
- ProjectLauncher
- SpatialUI
- SwiftUI
- XRIDebug

Sampleには以上のSceneが含まれています。本記事ではXR機能を説明するために4つのSceneを取り上げて説明します。

- **Balloon Gallery**
- **ImageTracking**
- **Manipulation**
- **MixedReality**

:::message
ProjectLauncherを最初にSceneに設定して、すべてのSceneを含めてビルドすると、複数のSceneを体験できるアプリをビルドすることができます。
:::

## Balloon Gallery

![](/images/gif/BallonGallery2.gif)

### 概要

- Sharedモード
- 風船を3DTouchしたら割る
  - 注視+ピンチによる選択
  - 直接タッチによる選択

### 実装ポイント
#### 3DTouchの実装

参考になるポイントは

- `UnityEngine.InputSystem.EnhancedTouch.Touch`の`Touch.activeTouches`でタッチ情報を獲得
- `Unity.PolySpatial.InputDevices`の`EnhancedSpatialPointerSupport.GetPointerState()`にてvisionOSのタッチ情報を取得
- `InputSystem.LowLevel`の
  - `SpatialPointerKind.IndirectPinch`で注視+ピンチによる選択
  - `SpatialPointerKind.Touch`で直接タッチによる選択

```csharp:GalleryInputManager.cs(一部抜粋)
using Unity.PolySpatial.InputDevices;
using UnityEngine;
using UnityEngine.InputSystem.EnhancedTouch;
using UnityEngine.InputSystem.LowLevel;
using Touch = UnityEngine.InputSystem.EnhancedTouch.Touch;
using TouchPhase = UnityEngine.InputSystem.TouchPhase;

public class GalleryInputManager : MonoBehaviour{    
    void OnEnable()
    {
        EnhancedTouchSupport.Enable();
    }
    void Update()
    {
        var activeTouches = Touch.activeTouches;

        if (activeTouches.Count > 0)
        {
            var primaryTouchData = EnhancedSpatialPointerSupport.GetPointerState(activeTouches[0]);
            if (activeTouches[0].phase == TouchPhase.Began)
            {
                // allow balloons to be popped with a poke or indirect pinch
                if (primaryTouchData.Kind == SpatialPointerKind.IndirectPinch || primaryTouchData.Kind == SpatialPointerKind.Touch)
                {
                    var balloonObject = primaryTouchData.targetObject;
                    if (balloonObject != null)
                    {
                        if (balloonObject.TryGetComponent(out BalloonBehavior balloon))
                        {
                            balloon.Pop();
                        }
                    }
                }
            }
        }
    }
}
```
## Manipulation

![](/images/gif/manipulator.gif)

### 概要

- Sharedモード
- 注視したら色が変わる
- つまむと掴める

### 実装ポイント

#### オブジェクトを注視すると色が変わる機能

- VisionOSHoverEffectコンポーネント
  - PolySpatial Componentの1つ。対象のオブジェクトに付与する
  - 目線を注視すると色が変わる。
  - MeshRendererとColliderのComponentが必要
  - 実装の中身は見れない (注視先の情報は取得できない)

![](/images/avp/visionOSHoverEffect.png)

## ImageTracking

![](/images/gif/imagetracking.gif)

### 概要

- Exclusive/Unboundedモード
- 画像を認識したら、オブジェクトを生成し追従する

### 実装ポイント

- ARFoundationのARTracked Image ManagerでOK
- PolySpatial特有の実装はなし

![](/images/avp/ARFoundation.png)

## MixedReality

![](/images/gif/mixedreality.gif)

### 概要

- Exclusive/Unboundedモード
- 壁や床を平面検出
- ハンドトラッキング
- ピンチしたらオブジェクト生成

### 実装ポイント

#### 平面検知は**ARFoundation**

- ARFoundationのARPlaneManagerコンポーネントを追加するだけ

![](/images/avp/2024-05-07-18-54-57.png)

#### ハンドトラッキングは**XRHands**
- 26個の関節のTransformを取得可能
- Sampleでは、親指のTipと人差し指のTipの距離を毎フレーム計算し、一定の距離以下ならObjectを生成する実装

![](/images/avp/2024-05-07-18-55-36.png)
*https://docs.unity3d.com/Packages/com.unity.xr.hands@1.4/manual/hand-data/xr-hand-data-model.html*

#### 目線は取得できないけど、カメラの向きは取れる

- Cameraのpositionから、Cameraのforward方向にRayを生成する実装

```csharp:PlaceOnPlane.cs
    [SerializeField]
    Transform m_CameraTransform;
    [SerializeField]
    GameObject m_HeadPoseReticle;
    GameObject m_SpawnedHeadPoseReticle;
    RaycastHit m_HitInfo;
    void Update()
    {
        if (Physics.Raycast(new Ray(m_CameraTransform.position, m_CameraTransform.forward), out m_HitInfo))
        {
            if (m_HitInfo.transform.TryGetComponent(out ARPlane plane))
            {
                m_SpawnedHeadPoseReticle.transform.SetPositionAndRotation(m_HitInfo.point, Quaternion.FromToRotation(m_SpawnedHeadPoseReticle.transform.up, m_HitInfo.normal));
            }
        }
    }
```

# まとめ

- Unity PolySpatialでは3種類のアプリパターンを開発できる
  - ① Mixed Reality
  - ② Virtual Reality - Fully Immersive
  - ③ Windowed Apps
- Mixed Realityアプリは、Shared(Bounded)モードとExclusive(Unbounded)モードがあり、Exclusive(Unbounded)モードではARkitの機能が使用可能
- 機能開発については、XR汎用パッケージ
  - ARFoundation
  - Input System
  - XR Hands
- を活用しつつ、visionOS固有の機能はPolySpatialを使用する 

