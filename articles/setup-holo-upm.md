---
title: "【HoloLens2×Unity】UPMでMRTKとMixed Reality OpenXRをインストールする"
emoji: "🔥"
type: "tech" # tech: 技術記事 / idea: アイデア
topics: ["Unity","HoloLens","Microsoft"]
published: true
---
# 背景
2022年現在、UnityによるHoloLens2開発では
- [**MixedRealityToolkit-Unity(MRTK)**](https://github.com/microsoft/MixedRealityToolkit-Unity)
- [**Mixed Reality OpenXR プラグイン**](https://docs.microsoft.com/ja-jp/windows/mixed-reality/develop/native/openxr)

の使用が推奨されています。[^1]

推奨されているのインストール方法として、公式チュートリアルでは

- [Mixed Reality Feature Tool](https://docs.microsoft.com/ja-jp/windows/mixed-reality/develop/unity/welcome-to-mr-feature-tool)

のインストール方法が紹介されています。Mixed Reality Feature ToolによるインストールはGUIでわかりやすいという一方で、パッケージデータをローカルにダウンロードして、そのローカルパスを参照する形になるため、git管理の対象がパッケージデータも行わなければならなくなります。

今回の記事は、Unity Package Manager (UPM)を使用することで、git管理対象を`manifest.json`のみにしたまま、パッケージを使用することができるようにします。

# 環境
|項目|version|
|---|---|
|OS|Windows11|
|Unity|2020.3.30f1|
|MRTK|2.7.3|
|Mixed Reality OpenXR|1.3.1|

# 手順

`Packages/manifest.json` で以下のように追加します。

```json:manifest.json
{ 
    "scopedRegistries": [
        {
            "name": "Microsoft Mixed Reality",
            "url": "https://pkgs.dev.azure.com/aipmr/MixedReality-Unity-Packages/_packaging/Unity-packages/npm/registry/",
            "scopes": [
                "com.microsoft.mixedreality",
            ]
        }
    ],  
    "dependencies": {
        /// 中略 ///
        "com.microsoft.mixedreality.openxr": "1.3.1",
        "com.microsoft.mixedreality.toolkit.foundation": "2.7.3",
        "com.microsoft.mixedreality.toolkit.tools": "2.7.3",
        "com.microsoft.mixedreality.toolkit.examples": "2.7.3"
    }
}
```

これにより、MRTK2.7.3とMixedReality OpenXR 1.3.1がインストールされます。

`Packages/manifest.json`以外で追加する方法としては、
[Edit]>[ProjectSetting]>[PackageManager]から操作します。

![](/images/hololens/2022-03-06-05-01-12.png)


これを確認するために
Unityのメニューバーから[Window]>[Package Manager]を選択すると、インストールされているのがわかると思います。

![](/images/hololens/2022-03-06-04-25-44.png)

また、UnityのProjectブラウザで確認できます。
![](/images/hololens/2022-03-06-05-02-11.png)

[^1]: https://docs.microsoft.com/ja-jp/windows/mixed-reality/develop/native/openxr
