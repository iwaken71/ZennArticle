---
title: "MacでUnityがインストールしたadbコマンドを使用する方法"
emoji: "🍎"
type: "tech" # tech: 技術記事 / idea: アイデア
topics: ["Unity", "Android", "Mac", "adb"]
published: true
---

# MacでUnityがインストールしたadbコマンドを使用する方法

UnityでAndroid開発をしている方にとって、adb（Android Debug Bridge）は非常に重要なツールです。本来はAndroid Studioをインストールすることでadbコマンドを使用できるようにしますが、この記事では、Unityにすでにインストールされているadbコマンドを使用する方法をお伝えします。

しかし、Unityによってインストールされたadbをコマンドラインから直接使用できるようにするには、少し設定が必要です。この記事では、その手順を詳しく解説します。

## 手順

### 1. Unityのインストールディレクトリを確認する

まず、Unityによってインストールされたadbがどこにあるかを確認する必要があります。通常、これはUnityのインストールディレクトリ内にあります。

### 2. adbの場所を特定する

一般的なパスは以下のようになります：

```
/Applications/Unity/Hub/Editor/[Unityのバージョン]/PlaybackEngines/AndroidPlayer/SDK/platform-tools/adb
```

ここで、`[Unityのバージョン]`は実際にインストールされているUnityのバージョンに置き換えてください。

### 3. パスを環境変数に追加する

ターミナルを開いて、以下のコマンドを実行します：

```bash
echo 'export PATH=$PATH:/Applications/Unity/Hub/Editor/[Unityのバージョン]/PlaybackEngines/AndroidPlayer/SDK/platform-tools' >> ~/.zshrc
```

注意：`[Unityのバージョン]`は、実際にインストールされているUnityのバージョンに置き換えてください。

### 4. 変更を反映させる

以下のコマンドを実行するか、ターミナルを再起動します：

```bash
source ~/.zshrc
```

### 5. adbコマンドが使用可能か確認する

ターミナルで以下のコマンドを実行します：

```bash
adb version
```

正しく設定されていれば、adbのバージョン情報が表示されるはずです。

## トラブルシューティング

もし上記の手順で問題が解決しない場合は、以下を確認してください：

1. Unityのバージョンが正しいか
2. パスが正確に入力されているか
3. ファイルの権限が適切に設定されているか

## まとめ

これらの手順を踏むことで、MacでUnityによってインストールされたadbコマンドを簡単に使用できるようになります。

これは本番開発ではおすすめできません。
クイックにadbコマンドを使用したいUnityエンジニアにとっての一つの選択肢として参考にしていただけると嬉しいです。

