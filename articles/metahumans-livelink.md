---
title: "【Meta Humans×Live Link】デジタルヒューマンをフェイシャルキャプチャで動かす"
emoji: "🔥"
type: "tech" # tech: 技術記事 / idea: アイデア
topics: ["UnrealEngine","DigitalHuman","MetaHumans"]
published: true
publication_name: "iwakenlab_book"
---
# この記事のゴール
Unreal EngineにからリリースされたMetaHumansのデジタルヒューマンに対して、iPhoneのフェイシャルキャプチャを用いてリアルタイムで顔を動かします。

こんな感じで！

https://twitter.com/iwaken71/status/1359820023485763585?s=20

# 手順

- MetaHumansをimport
- Facial Capture用のレベルを作成
- iPhoneにLive Link Face Appをインストール&起動
- Live Link用の設定
- 再生して確認

# 開発環境

- Unreal Engine4.26 (以下UE4)
    - 現在4.26のみ動作します
- Windows10
- iPhone11
    - FaceID搭載の機種であれば可能
- Wifi環境

# MetaHumansをimport

こちらの記事でimportお願いします！
https://zenn.dev/iwaken71/articles/metahumans-unrealengine-sample

# Facial Capture用のレベルを作成

- 空のレベルを新規作成し、"Facial"などと名前を付ける
- Content/SampleMetaHumans/metahuman_004/BP_metahuman_004をレベルに追加
- BP_metahuman_004のTransformのLocationを(0,0,0),Rotation(0,0,90)に設定する
- Persistent LevelにMH_Gen4Lightingを追加

空のレベルを新規作成し、"Facial"などと名前を付ける

![image](https://user-images.githubusercontent.com/10010842/107638846-769eda80-6cb3-11eb-87f5-76eaf88ad407.png)

Content/SampleMetaHumans/metahuman_004/BP_metahuman_004をレベルに追加

![image](https://user-images.githubusercontent.com/10010842/107638943-98985d00-6cb3-11eb-8b5c-b009027b6e0c.png)

BP_metahuman_004のTransformのLocationを(0,0,0),Rotation(0,0,90)に設定する

![image](https://user-images.githubusercontent.com/10010842/107639052-bbc30c80-6cb3-11eb-9b58-55d7ab2e3ffa.png =540x)

Persistent LevelにMH_Gen4Lightingを追加
Levelsウィンドウが存在しない場合は [Window]>[Levels]を選択。

![image](https://user-images.githubusercontent.com/10010842/107639187-e3b27000-6cb3-11eb-9dae-d012fe01269c.png)

# iPhoneにLive Link Face Appをインストール&起動

- iPhoneにインストール&起動
- PCとiPhoneで同じWifiに入る
- [設定]>[Live Link]>[ターゲット追加]>PCのIPアドレスを入力
- お好み設定
    - 頭の回転をストリームにチェックを入れる

iPhoneにインストール
https://apps.apple.com/us/app/live-link-face/id1495370836

[設定]>[Live Link]>[ターゲット追加]>PCのIPアドレスを入力
![image](https://user-images.githubusercontent.com/10010842/107649647-039c6080-6cc1-11eb-8021-cd0428fa54ad.png =540x)

頭の回転をストリームにチェックを入れる (お好み)
チェックを入れると頭の回転も反映させるようになる。
![image](https://user-images.githubusercontent.com/10010842/107652430-eae17a00-6cc3-11eb-83a9-77279026a763.png =540x)

# Live Link用の設定

UE4の[Window]>[Live Link]を選択する。

iPhoneのLive Link Face Appのカメラモードで自分の顔を認識させている状態で、UE4のLive Linkがつながっているか確認する。

![image](https://user-images.githubusercontent.com/10010842/107652914-6a6f4900-6cc4-11eb-91d2-3b380d3dbdc0.png =540x)

BP_metahuman_004を選択し、[LLink Face Subj]にて**iPhone**を選択する。
お好みで[LLink Face Head]にチェックを入れる。チェックを入れると頭の回転も反映するようになる。
![image](https://user-images.githubusercontent.com/10010842/107654451-064d8480-6cc6-11eb-82fa-030dd7e016ac.png)

# 再生して確認

UE4のプレイボタンで再生！

@[youtube](txy0YCAAH4o)