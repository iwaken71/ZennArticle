---
title: "8th Wall OSS × three.js で Self-Host Image Tracking サンプルを動かすまで"
emoji: "📸"
type: "tech"
topics: ["8thwall", "WebXR", "AR", "threejs", "GitHub"]
published: true
---

## はじめに

2026年2月28日、8th Wall のホスティングプラットフォーム（Console、Cloud Editor、Studio）へのアクセスが終了しました（新規プロジェクト作成・既存プロジェクトへのアクセスを含む）。既存の公開済みホストについての取り扱いは[公式アナウンス](https://www.8thwall.com/blog/post/208587408737/8th-wall-open-source)を参照してください。そして 3月2日、8th Wall のエンジンフレームワークとツール群が[オープンソースとして公開](https://www.8thwall.com/blog/post/208587408737/8th-wall-open-source)されました。

> **OSS 化の範囲について**: エンジンフレームワーク（MIT ライセンス）と XR Extras、Image Target CLI はオープンソースですが、**SLAM モジュール（`xr-slam.js`）はバイナリ配布のみ**であり、ソースコードは非公開です。

これにより、無料で高精度のWebARのImage Trackingを使えるようになりました。

本記事では、8th Wall OSS × three.js で Self-Host Image Tracking サンプルを動かすまでの手順を解説します。

### 完成したもの

https://x.com/iwaken71/status/2029401132058218786

自分のアイコンの画像をスマホカメラで映すと、アイコン Cube が出てくる AR 体験です。

今回、Cubeの演出の実装に関しては割愛しています。

### この記事のポジション

[公式ブログ](https://www.8thwall.com/blog/post/208587408737/8th-wall-open-source)では画像トラッキングのサンプルとして **8th Wall Desktop** での[手法が案内](https://github.com/8thwall/studio-image-targets-example)されていますが、この記事では Desktopアプリ を使わず、**通常の Web + Three.js の構成**でセルフホスト AR を作り切る方法を解説します。

その理由として、AIコーディング時代において、すべてコードで実装できる方が効率的であると考えているからです。

方針としては、8thWallの[webレポジトリ](https://github.com/8thwall/web)にあるthree.jsの画像トラッキング（Image Targets）サンプルをベースに、OSS 版エンジンへの移行手順を一通り説明します。さらに、オリジナルの画像をターゲットに追加する方法や、スマホでの効率的なテスト方法も紹介します。

### つまづきやすいポイント

8thWall OSS 活用のサンプルプロジェクトを作るに当たって、AIに雑にやらせるだけでは達成しにくいポイントを以下にまとめます。

1. **サンプルプロジェクトのコピーから始める** — ゼロから書くのではなく、[8thwall/web](https://github.com/8thwall/web) リポジトリのサンプルをコピーして土台にする。
2. トラッキングする画像の登録するために、 `npx @8thwall/image-target-cli@latest` を使う — Console へのアップロードは不要になり、ローカルで JSON を生成する
3. **コピーしたサンプルに対して Engine 移行作業が必要** — CDN 参照の削除、API キーの除去、`imageTargetData` の fetch 追加など、コードの書き換えが発生する
4. スマホで動作確認するために、httpsサーバーを立てて動作させる必要がある

ここらへんを理解しておくと、ご自身でAIコーディングするときにも実現しやすいかと思います。

## 前提環境

- macOS（Intel/Apple Silicon どちらも可）
- Node.js 18 以上
- npm
- Git

## 使用する OSS コンポーネント

| コンポーネント | リポジトリ | 用途 |
|---|---|---|
| Engine Binary | [8thwall/engine](https://github.com/8thwall/engine) | AR エンジン本体（SLAM チャンク含む）※SLAM はバイナリ配布 |
| Image Target CLI | [@8thwall/image-target-cli](https://www.npmjs.com/package/@8thwall/image-target-cli) | 画像 → ターゲット JSON の生成 |
| XR Extras | [8thwall/8thwall](https://github.com/8thwall/8thwall/tree/main/packages/xrextras) | ローディング UI、エラー表示 |

## Step 1: flyer サンプルのコピー

8thWallのGithubには、過去に利用されていたセルフホスト向けのサンプルプロジェクトがいくつかあります。今回はthree.jsかつ画像トラッキングのサンプル [Three.js flyer サンプル](https://github.com/8thwall/web/tree/master/examples/threejs/flyer) を使います。このサンプルは、チラシ画像をカメラで映すとクラゲの 3D モデルや動画をオーバーレイ表示する AR アプリです。

### サンプルプロジェクトの取得

```bash
git clone --depth 1 https://github.com/8thwall/web.git /tmp/8thwall-web
mkdir my-ar-project
cp /tmp/8thwall-web/examples/threejs/flyer/* my-ar-project/
cd my-ar-project
```

### コピーされるファイル

```
my-ar-project/
  index.html              # メイン HTML（Three.js import map、SDK 読み込み）
  index.js                # AR ロジック（パイプライン、ターゲット検出、シーン管理）
  index.css               # 全画面カメラフィードのスタイル
  jellyfish-model.glb     # クラゲの 3D モデル
  jellyfish-video.mp4     # クラゲの動画
  flyer.jpg               # チラシ画像
  targets/                # トラッキング対象の元画像
    model-target.jpg
    video-target.jpg
```

### この時点のコードの状態

コピーしたサンプルは **CDN 版（プラットフォーム版）** 向けに書かれています。`index.html` を見ると、XR Extras と 8th Wall エンジンを CDN から読み込んでおり、API キーが必要な構成です。

```html
<!-- XR Extras - CDN から読み込み -->
<script src="//cdn.8thwall.com/web/xrextras/xrextras.js"></script>

<!-- 8th Wall エンジン - API キーが必要 -->
<script async src="//apps.8thwall.com/xrweb?appKey=XXXXXXXX"></script>
```

`index.js` の `onxrloaded` 関数は同期的で、画像ターゲットは Console 側の autoload に依存しています。

```javascript
const onxrloaded = () => {
  XR8.XrController.configure({disableWorldTracking: true})
  XR8.addCameraPipelineModules([...])
  XR8.run({canvas: document.getElementById('camerafeed')})
}
```

Console が廃止された今、このままでは動きません。ここから OSS 版エンジンに移行していきます。

## Step 2: Engine Binary のダウンロード

[8thwall/engine](https://github.com/8thwall/engine) リポジトリから `xr-standalone.zip` をダウンロードし、プロジェクト内に展開します。

このファイルは **Git LFS** で管理されており、Releases ページは存在しません。`git clone` でリポジトリごと取得するのが確実です。

```bash
# 1. git-lfs のインストール（未インストールの場合）
brew install git-lfs
git lfs install

# 2. リポジトリをクローン（LFS ファイルも自動ダウンロード）
git clone --depth 1 https://github.com/8thwall/engine.git /tmp/8thwall-engine

# 3. プロジェクトの external/xr/ に展開
mkdir -p external/xr
unzip /tmp/8thwall-engine/xr-standalone.zip -d external/xr
```

> **補足**: `git-lfs` がインストールされていない状態でクローンすると、`xr-standalone.zip` が LFS ポインタファイル（小さなテキスト）になります。その場合は `cd /tmp/8thwall-engine && git lfs pull` を実行すると実ファイルに差し替わります。`git-lfs` を使わずに ZIP だけ取得したい場合は `curl -L https://media.githubusercontent.com/media/8thwall/engine/main/xr-standalone.zip -o xr-standalone.zip` でも取得できます。

展開後のディレクトリ構造:

```
external/xr/
  xr.js           # メインエンジン（約 1MB）
  xr-slam.js      # SLAM チャンク（約 5.3MB、画像ターゲットに必要）
  xr-face.js      # Face チャンク（約 7.3MB、今回は使わない）
  LICENSE
  resources/
    media-worker.js
    semantics-worker.js
    powered-by.svg
```

## Step 3: XR Extras のビルド

8th Wall モノレポをクローンし、XR Extras をビルドします。

```bash
git clone --depth 1 https://github.com/8thwall/8thwall.git /tmp/8thwall-oss
cd /tmp/8thwall-oss/packages/xrextras
cp ../../LICENSE .
npm install
npm run build
```

> `xrextras` パッケージのビルドにはディレクトリ内に `LICENSE` ファイルが必要です。モノレポのルートにある MIT ライセンスファイルをコピーしてからビルドしてください。

ビルド成果物をプロジェクトにコピーします。プロジェクトのディレクトリに移動してから実行してください。

```bash
mkdir -p external
cp -r /tmp/8thwall-oss/packages/xrextras/dist/external/xrextras ./external
```

## Step 4: 画像ターゲットのコンパイル

ここが従来と大きく異なるポイントです。以前は Console に画像をアップロードして autoload を有効化する必要がありましたが、OSS 版では **`@8thwall/image-target-cli`** でローカルにコンパイルできます。npm パッケージとして公開されているため、`npx` で即座に実行できます。

### ターゲット画像のコンパイル

CLI は対話式です。画像パスを入力し、タイプ（flat/cylinder/cone）を選び、出力先を指定します。

```bash
npx @8thwall/image-target-cli@latest
```

```
Enter the path to the image file: ./targets/model-target.jpg
Select the image type:
1) flat (default)
Use default crop? [Y/n]: Y
Enter the output folder: ./image-targets
Enter a name for the image target: model-target
Image target data saved to: ./image-targets/model-target.json
```

同様に `video-target.jpg` も処理します。

### 生成されるファイル

各ターゲットにつき以下のファイルが生成されます（ファイル名はバージョンによって若干異なる場合があります）。

```
image-targets/
  model-target.json              # メタデータ（エンジンに渡す）
  model-target_original.jpg      # 元画像
  model-target_cropped.jpg       # クロップ後
  model-target_luminance.jpg     # グレースケール 480x640（特徴抽出用）
  model-target_thumbnail.jpg     # サムネイル 263x350
```

### JSON の中身

```json
{
  "imagePath": "image-targets/model-target_luminance.jpg",
  "metadata": null,
  "name": "model-target",
  "type": "PLANAR",
  "properties": {
    "left": 0,
    "top": 0,
    "width": 995,
    "height": 1326,
    "isRotated": false,
    "originalWidth": 995,
    "originalHeight": 1326
  },
  "resources": {
    "originalImage": "model-target_original.jpg",
    "croppedImage": "model-target_cropped.jpg",
    "thumbnailImage": "model-target_thumbnail.jpg",
    "luminanceImage": "model-target_luminance.jpg"
  }
}
```

> **注意**: JSON の構造（フィールド名・階層）は CLI のバージョンによって変わる可能性があります。実際に生成されたファイルを必ず確認してください。

`imagePath` はエンジンが特徴抽出に使う画像のパスです。プロジェクトルートからの相対 URL として解釈されます。

## Step 5: コードの移行

Step 1 でコピーした flyer サンプルのコードを、OSS 版エンジンに対応させます。変更が必要なのは `index.html` と `index.js` の 2 ファイルです。

### 変更点の全体像

元の flyer サンプルからの主な変更点は以下の通りです。

| ファイル | 変更内容 |
|---|---|
| `index.html` | CDN → ローカルパス、API キー削除、`data-preload-chunks="slam"` 追加 |
| `index.js` | `onxrloaded` を async 化、`imageTargetData` を `fetch()` で読み込み、`THREE.RGBFormat` → `THREE.RGBAFormat` |

### index.html の変更

CDN 参照をローカルパスに置き換え、API キーを削除します。

**元のサンプル:**

```html
<script src="//cdn.8thwall.com/web/xrextras/xrextras.js"></script>
<script async src="//apps.8thwall.com/xrweb?appKey=XXXXXXXX"></script>
```

**OSS 版:**

```html
<script src="./external/xrextras/xrextras.js"></script>
<script async src="./external/xr/xr.js" data-preload-chunks="slam"></script>
```

`data-preload-chunks="slam"` は画像ターゲットの検出に必要な SLAM モジュールを事前読み込みする指定です。

### index.js の変更

最大の変更点は `onxrloaded` 関数です。プラットフォーム版では Console が画像ターゲットを自動配信していましたが、OSS 版では自分で JSON を `fetch()` してエンジンに渡す必要があります。

**元のサンプル:**

```javascript
const onxrloaded = () => {
  XR8.XrController.configure({disableWorldTracking: true})
  XR8.addCameraPipelineModules([...])
  XR8.run({canvas: document.getElementById('camerafeed')})
}
```

**OSS 版:**

```javascript
const onxrloaded = async () => {
  const [modelTarget, videoTarget] = await Promise.all([
    fetch('./image-targets/model-target.json').then(r => r.json()),
    fetch('./image-targets/video-target.json').then(r => r.json()),
  ])

  XR8.XrController.configure({
    disableWorldTracking: true,
    imageTargetData: [modelTarget, videoTarget],
  })

  XR8.addCameraPipelineModules([...])
  XR8.run({canvas: document.getElementById('camerafeed')})
}
```

パイプラインモジュール（`XR8.GlTextureRenderer`, `XR8.Threejs` 等）やイベントハンドラ（`reality.imagefound` / `imageupdated` / `imagelost`）はそのまま動作します。

### Three.js の互換性修正

Three.js r137（v0.137.0）以降で `THREE.RGBFormat` が廃止されています。v0.172.0 などの現行バージョンを使用している場合は `THREE.RGBAFormat` に置き換えます。

```diff
- texture.format = THREE.RGBFormat
+ texture.format = THREE.RGBAFormat
```

## Step 6: オリジナル画像をターゲットに追加する

サンプルの画像ターゲットが動いたら、次は自分のオリジナル画像をトラッキング対象に追加してみましょう。ここでは例として `iwaken-target`（名刺の画像）を追加する手順を示します。

### 6-1. 元画像の準備

トラッキング対象にしたい画像（JPG / PNG）を用意します。

**画像選びのポイント:**
- 高コントラストで特徴点が多い画像が最適（テキスト、図形、写真などが混在しているとベスト）
- 単色の面が広い画像や、繰り返しパターンの多い画像は認識精度が落ちる
- 推奨解像度: 480px 以上

### 6-2. image-target-cli でコンパイル

Step 4 と同様に `npx` でコンパイルします。

```bash
npx @8thwall/image-target-cli@latest
```

対話式プロンプトに以下のように入力します（パスは自分の環境に合わせてください）。

```
Enter the path to the image file: /path/to/project/targets/iwaken-target.jpg
Select the image type:
1) flat (default)
Use default crop? [Y/n]: Y
Enter the output folder: /path/to/project/image-targets
Enter a name for the image target: iwaken-target
Image target data saved to: /path/to/project/image-targets/iwaken-target.json
```

これで `image-targets/` に以下のファイルが生成されます。

```
image-targets/
  iwaken-target.json              # メタデータ
  iwaken-target_original.jpg      # 元画像コピー
  iwaken-target_cropped.jpg       # クロップ後
  iwaken-target_luminance.jpg     # グレースケール（特徴抽出用）
  iwaken-target_thumbnail.jpg     # サムネイル
```

### 6-3. index.js の修正

ターゲットを 1 つ追加するたびに、**3 箇所** を修正する必要があります。

#### 修正箇所 1: ターゲット JSON の fetch 追加

`onxrloaded` 関数内の `Promise.all` に、新しいターゲットの fetch を追加します。

```javascript
const onxrloaded = async () => {
  const [modelTarget, videoTarget, iwakenTarget] = await Promise.all([
    fetch('./image-targets/model-target.json').then(r => r.json()),
    fetch('./image-targets/video-target.json').then(r => r.json()),
    fetch('./image-targets/iwaken-target.json').then(r => r.json()),  // 追加
  ])
```

> **注意: JavaScript の変数名は数字で始められません。** ターゲット名が `3dgsmeetup` のように数字始まりの場合、`3dgsmeetupTarget` は構文エラーになります。`meetup3dgsTarget` や `target3dgsmeetup` のように英字始まりの変数名を使ってください。

#### 修正箇所 2: imageTargetData への登録

`XR8.XrController.configure()` の `imageTargetData` 配列に、fetch した結果を追加します。ここに登録しないとエンジンがそのターゲットを認識対象として扱いません。

```javascript
  XR8.XrController.configure({
    disableWorldTracking: true,
    imageTargetData: [modelTarget, videoTarget, iwakenTarget],  // 追加
  })
```

#### 修正箇所 3: showTarget / hideTarget のイベントハンドラ

`showTarget` と `hideTarget` の `detail.name` 判定に、新しいターゲット名を追加します。`detail.name` は JSON ファイル内の `name` フィールドと**完全一致**する必要があります。

今回は既存の `model-target` と同じ 3D モデルを表示させたいので、`||` で条件を追加しました。

```javascript
const showTarget = ({detail}) => {
  if (detail.name === 'model-target' || detail.name === 'iwaken-target') {
    model.position.copy(detail.position)
    model.quaternion.copy(detail.rotation)
    model.scale.set(detail.scale, detail.scale, detail.scale)
    model.visible = true
  }
  // ...
}

const hideTarget = ({detail}) => {
  if (detail.name === 'model-target' || detail.name === 'iwaken-target') {
    model.visible = false
  }
  // ...
}
```

#### まとめ: 修正箇所チェックリスト

ターゲットを追加する際は、以下の 3 点を漏れなく修正してください。

| # | 修正箇所 | 何をするか |
|---|---|---|
| 1 | `Promise.all` 内の fetch | 新しい JSON ファイルを読み込む |
| 2 | `imageTargetData` 配列 | エンジンに認識対象として登録する |
| 3 | `showTarget` / `hideTarget` | ターゲット検出時の表示・非表示ロジックを追加する |

> **ターゲット数が増えてきたら**: 上記のように 3 箇所をそれぞれ修正する方式は、ターゲットが 2〜3 個なら十分ですが、数が増えると修正漏れが発生しやすくなります。設定配列で一元管理し、fetch・登録・表示ロジックをすべてループで処理する**設定駆動（config-driven）方式**へのリファクタリングを検討してください。

## Step 7: スマホでテストする

AR アプリはカメラを使うため、最終的な動作確認はスマートフォンで行う必要があります。ブラウザのカメラ API（`getUserMedia`）は **Secure Context（HTTPS または localhost）でのみ動作します**。`localhost` はブラウザ例外としてそのまま使えますが、スマホから PC のサーバーにアクセスする場合は HTTPS が必要です。

:::message
**Cloudflare Tunnel でスマホ確認**

[Cloudflare Quick Tunnel](https://developers.cloudflare.com/cloudflare-one/networks/connectors/cloudflare-tunnel/do-more-with-tunnels/trycloudflare/) を使うと、アカウント登録なしでローカルの HTTP サーバーを即座に HTTPS 公開できます。

```bash
# 事前準備
brew install cloudflared

# ターミナル 1: ローカル HTTP サーバーを起動
python3 -m http.server 8082

# ターミナル 2: 同じポート番号を指定してトンネルを作成
cloudflared tunnel --url http://localhost:8082
```

起動すると、ターミナルにボックスが表示されます。

```
+--------------------------------------------------------------------------------------------+
|  Your quick Tunnel has been created! Visit it at (it may take some time to be reachable):  |
|  https://xxxxxxxx-yyyy.trycloudflare.com                                                   |
+--------------------------------------------------------------------------------------------+
```

**ボックス内の `https://xxxx.trycloudflare.com`** がスマホでアクセスする URL です。Cloudflare 側が HTTPS を提供するため、スマホのカメラも正常に動作します。

> 2 つのコマンドで指定するポート番号が一致していないと `502 Bad Gateway` になります。
:::

### テスト時のコツ

- **画像ターゲットの印刷**: トラッキング対象の画像は、PC の画面に表示するよりも**印刷して**使う方が認識精度が上がります。画面の反射やモアレがノイズになるためです
- **明るい環境**: 暗い場所ではカメラの映像品質が落ち、認識精度が低下します
- **距離と角度**: 画像から 30〜50cm 程度の距離で、正面に近い角度がベストです
- **ブラウザキャッシュ**: 変更が反映されない場合は、スーパーリロード（iOS Safari: URL バーの再読み込みボタンを長押し）またはキャッシュクリアを試してください

## 最終的なファイル構成

```
my-ar-project/
  index.html              # ローカルエンジン参照に変更済み
  index.js                # imageTargetData を fetch で読み込み
  index.css
  serve.py                # ローカル HTTPS サーバー
  jellyfish-model.glb     # 3D モデル
  jellyfish-video.mp4     # 動画
  external/
    xr/                   # Engine Binary（Step 2 で配置）
      xr.js
      xr-slam.js
      xr-face.js
      ...
    xrextras/             # XR Extras（Step 3 でビルド・配置）
      xrextras.js
      resources/
  image-targets/           # CLI で生成したターゲットデータ（Step 4 で生成）
    model-target.json
    model-target_luminance.jpg
    video-target.json
    video-target_luminance.jpg
    iwaken-target.json          # オリジナル画像ターゲット（Step 6 で追加）
    iwaken-target_luminance.jpg
    ...
  targets/                 # 元画像（CLI 入力用に保持）
    model-target.jpg
    video-target.jpg
    iwaken-target.jpg           # オリジナル画像
```

## まとめ

### 移行で変わったこと

| 項目 | 旧（プラットフォーム版） | 新（OSS 版） |
|---|---|---|
| API キー | 必要 | **不要** |
| 画像ターゲット登録 | Console にアップロード | **CLI でローカルコンパイル** |
| Authorized Domains | Console で登録 | **不要** |
| SDK 読み込み | CDN（`apps.8thwall.com`） | **ローカルファイル** |
| ホスティング | 8th Wall or 自前（ドメイン制限あり） | **どこでも OK** |

### ハマりポイント: XR Extras のリソース画像が壊れる

XR Extras をプロジェクトに配置する際、**ディレクトリの配置場所**に注意が必要です。

XR Extras の webpack ビルド成果物は、内部で画像パスを `./external/xrextras/resources/...` とハードコードしています。これは webpack の出力構成が `dist/external/xrextras/` を前提としているためです。

そのため、`xrextras/` をプロジェクトルートに直接置くと、パスが一致せずローディング画面の画像が壊れます。

```
# NG: パスが一致しない
xrextras/
  xrextras.js         → 内部で ./external/xrextras/resources/... を参照
  resources/           → 実際は ./xrextras/resources/... にある

# OK: パスが一致する
external/
  xrextras/
    xrextras.js       → 内部で ./external/xrextras/resources/... を参照
    resources/         → 実際も ./external/xrextras/resources/... にある
```

Engine Binary（`xr/`）も同じ `external/` 配下にまとめると、8th Wall OSS の公式サンプルと同じ構成になります。

```bash
mkdir -p external
cp -r /tmp/8thwall-oss/packages/xrextras/dist/external/xrextras ./external/xrextras
unzip xr-standalone.zip -d external/xr
```

### 参考リンク

- [8th Wall OSS 公式サイト](https://8thwall.org)
- [8th Wall Engine Binary](https://github.com/8thwall/engine)
- [8th Wall Monorepo](https://github.com/8thwall/8thwall)
- [flyer サンプル（元プロジェクト）](https://github.com/8thwall/web/tree/master/examples/threejs/flyer)
- [Self-Hosted Migration Guide](https://www.8thwall.com/docs/migration/self-hosted/)
- [OSS 公開ブログ記事](https://www.8thwall.com/blog/post/208587408737/8th-wall-open-source)
