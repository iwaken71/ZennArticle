---
title: "【HoloLens2】UE4.26にUX Tools for Unrealをインストールする"
emoji: "🔥"
type: "tech" # tech: 技術記事 / idea: アイデア
topics: ["UnrealEngine","HoloLens","UE4","VisualStudio","Microsoft"]
published: true
---

# はじめに

この記事では、HoloLens2×UE4に対して、UX Tools for Unreal v0.11.0をインストールします。
このことによって、HandをインターフェイスとしたUIが使用できるようになります。

https://github.com/microsoft/MixedReality-UXTools-Unreal/releases/tag/v0.11.0
![image](https://user-images.githubusercontent.com/10010842/104896913-17eb8700-59bb-11eb-806e-78597184b3c4.png)

# 参考記事

https://docs.microsoft.com/ja-jp/windows/mixed-reality/develop/unreal/tutorials/unreal-uxt-ch4
https://docs.microsoft.com/ja-jp/windows/mixed-reality/develop/unreal/tutorials/unreal-uxt-ch5
https://github.com/microsoft/MixedReality-UXTools-Unreal/releases/tag/v0.11.0

# 前提条件

https://zenn.dev/iwaken71/articles/6792badbdec8d6

こちらの記事の設定を行っている前提です。

# 開発環境

- Windows10 Pro
- Unreal Engine4.26 (以下Unreal)
- Visual Studio2019
- HoloLens2
- UX Tools for Unreal v0.11.0

# 手順

1. UX Tools for Unrealをダウンロード
2. ハンドインタラクションアクターを生成する

# UX Tools for Unrealをダウンロード

- Releaseページからダウンロード
- Pluginsフォルダに移動
- UE4エディタを再起動

## Releaseページからダウンロード

[UX Tools for Unreal v0.11.0](https://github.com/microsoft/MixedReality-UXTools-Unreal/releases/tag/v0.11.0)にアクセス。
UXTools.0.11.0.zipをクリックしてダウンロード。
![image](https://user-images.githubusercontent.com/10010842/104871195-c8db2d00-598d-11eb-97ac-57a1a1b69ee9.png)

## Pluginsフォルダに移動

**ディレクトリ構造**
- {ProjectName}
    - Config
    - Contents
    - ...
    - Plugins (存在しない場合新しく作成)
        - UXTools (このフォルダ以下にzipファイルを展開する)
            - Binaries
            - Content
            - ...
            - Resources
            - Shaders
            - Source
            - UXTools.uplugin
    - {ProjectName}.uproject

## UE4エディタを再起動

UE4エディタを開き

- [Edit]>[Plugins]を選択
- Mixed Reality UX Toolsを探す
- Enabledにチェックを入れて再起動

![image](https://user-images.githubusercontent.com/10010842/104871842-7f8bdd00-598f-11eb-9180-c73a17a1947d.png)

### 確認方法

 {ProjectName}.uprojectをメモ帳などのテキストエディタで開く。
下のようにUXToolsが導入されていれば成功。

```json
		{
			"Name": "UXTools",
			"Enabled": true,
			"MarketplaceURL": "com.epicgames.launcher://ue/marketplace/product/f9f9cddaf5834ad1abeda49da34adf85",
			"SupportedTargetPlatforms": [
				"Win64",
				"HoloLens",
				"Android"
			]
		},
```

# ハンドインタラクションアクターを生成する

## 説明

UX 要素とのハンド インタラクションは、ハンドインタラクションアクターを使用して行われます。これにより、近接および遠隔のインタラクションのポインターとビジュアルが作成および起動されます。

- 近接インタラクション: 人差し指と親指で要素をつまむか、指先でそれらをつつくこと。
- 遠隔インタラクション: 仮想ハンドの光線を要素にあてて、人差し指と親指を一緒に押すこと。

![image](https://user-images.githubusercontent.com/10010842/104896964-2c2f8400-59bb-11eb-9b02-4104a74bb7e9.png)

MRPawn にハンドインタラクションアクターを追加すると、次の処理が行われます。

- ポーンの人差し指の先端にカーソルを追加します。
- ポーンを介して操作できる多関節ハンド入力イベントを提供します。
- 仮想ハンドの手のひらから伸びる手の光線を通して、遠隔インタラクションによる入力イベントを許可します。

## 手順

準備ができたら、MRPawn ブループリントを開き、 [Event Graph]に移動します。

- Functionを追加 "InitializeHandSetting"などと名前を付ける
- Event BeginPlayとInitializeHandSettingと接続する
![image](https://user-images.githubusercontent.com/10010842/104895725-91827580-59b9-11eb-830c-23c47413835b.png)

- 右クリックしSpawn Actor from Classを2つ追加
    - [Class]を[Uxt Hnad Interaction Actor]に選択
    - それぞれ[Hand]をLeft,Rightを選択
- 右クリックし[Get a reference to self]を選択
    - それぞれの[Owner]につなげる
- 右クリックし[Make Transform]を追加
    - 値はデフォルトのまま
    - それぞれの[Spawn Transform]につなげる    
![image](https://user-images.githubusercontent.com/10010842/104895572-6a2ba880-59b9-11eb-9566-e0937c6cbadd.png)

# おわりに

この状態でPlayを押すとHandのシミュレーションが出現します。

この状態で
- "W" "A" "S" "D"を押して前後左右移動する
- マウスを動かして周りを見渡す

のような動きをすることができます。

![image](https://user-images.githubusercontent.com/10010842/104897539-d60f1080-59bb-11eb-8bf9-e858c309e02b.png)








