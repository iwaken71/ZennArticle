---
title: "[OpenClaw] Mac を Tailscale + SSH でリモートアクセス可能にする"
emoji: "🔐"
type: "tech"
topics: ["OpenClaw", "Tailscale", "SSH", "Mac", "リモートアクセス"]
published: false
publication_name: "iwakenlab_book"
---

# はじめに

OpenClaw を使った AI アシスタント環境を外出先からも使いたい。そんなときに便利なのが **Tailscale + SSH** の組み合わせです。

この記事では、Mac Studio（または Mac）を外部からセキュアに SSH 接続できるようにする手順を解説します。

## 完成イメージ

```bash
# ノートPC から Mac Studio に一発接続
ssh mac-studio
```

ポート開放不要、VPN 不要、パスワードなしでセキュアに接続できます 🎉

# なぜ Tailscale？

| 方法 | メリット | デメリット |
|------|----------|------------|
| **Tailscale（採用）** | 簡単・安全・ポート開放不要 | Tailscale アカウント必要 |
| ポートフォワーディング | 追加ソフト不要 | ルーター設定必要・セキュリティリスク |
| Cloudflare Tunnel | 無料・安全 | 設定がやや複雑 |

Tailscale は **WireGuard ベースの VPN** で、設定が簡単でセキュリティも高いため、今回はこれを採用します。

# 環境

- **接続先:** Mac Studio (macOS Sequoia 15.2)
- **接続元:** ノートPC (macOS / Windows / Linux)
- **ツール:**
  - Tailscale（無料プラン）
  - OpenSSH（macOS 標準）

# 手順

## 1. Mac 側：リモートログインを有効化

**システム設定 → 一般 → 共有 → リモートログイン** をオンにします。

または Terminal で：

```bash
sudo systemsetup -setremotelogin on
```

これで SSH サーバー（sshd）が起動します。

## 2. Mac 側：Tailscale をインストール

公式サイトからインストール：
<https://tailscale.com/download>

インストール後、メニューバーの Tailscale アイコンから **Log in** します。

ログインすると、Tailscale IP（`100.x.x.x`）が割り当てられます。この IP をメモしておきます。

例: `100.77.242.20`

## 3. 接続元 PC：Tailscale をインストール

接続元の PC にも Tailscale をインストールし、**同じアカウント**でログインします。

これで Mac Studio と接続元 PC が同じ Tailscale ネットワークに参加します。

## 4. 接続元 PC：SSH 接続テスト

まずは IP アドレスで接続してみます：

```bash
ssh ユーザー名@100.77.242.20
```

初回はパスワード入力が必要です。接続できれば成功！

## 5. SSH 鍵認証を設定（推奨）

パスワード認証より安全な鍵認証を設定します。

### 接続元 PC で鍵を生成

```bash
ssh-keygen -t ed25519
```

全部 Enter でOK。これで `~/.ssh/id_ed25519` と `~/.ssh/id_ed25519.pub` が生成されます。

### 公開鍵を Mac に送る

```bash
ssh-copy-id ユーザー名@100.77.242.20
```

これで次回からパスワードなしで接続できます 🔐

## 6. SSH config で接続を簡単に

毎回 IP を入力するのは面倒なので、`~/.ssh/config` にエイリアスを設定します。

接続元 PC で以下を実行：

```bash
mkdir -p ~/.ssh
cat >> ~/.ssh/config << 'EOF'
Host mac-studio
    HostName 100.77.242.20
    User ユーザー名
EOF
```

これで：

```bash
ssh mac-studio
```

だけで接続できるようになります！✨

## 7. 複数 PC から接続する場合

新しい PC を追加するときは、その PC で：

1. Tailscale をインストール & 同じアカウントでログイン
2. SSH 鍵を生成（`ssh-keygen -t ed25519`）
3. SSH config に追記
4. 公開鍵を Mac に登録（`ssh-copy-id mac-studio`）

または、公開鍵（`~/.ssh/id_ed25519.pub` の内容）を Mac の `~/.ssh/authorized_keys` に手動で追記する方法もあります。

# OpenClaw での活用

この設定があれば、外出先から：

- OpenClaw のログを確認
- Workspace のファイルを編集
- スクリプトを実行
- Git で変更を push/pull

など、あらゆる操作がリモートでできます。

VS Code の Remote SSH 拡張を使えば、ローカルと同じように開発できます 👍

# まとめ

Tailscale + SSH の組み合わせで、Mac を外部から安全にリモートアクセス可能にしました。

**ポイント:**
- ✅ ポート開放不要（Tailscale が P2P 接続を確立）
- ✅ セキュア（WireGuard + SSH 鍵認証）
- ✅ 簡単（数分で設定完了）
- ✅ 無料（Tailscale の無料プランで十分）

OpenClaw のような AI アシスタント環境を常に手元に置けるのは便利です。ぜひ試してみてください！

# 参考リンク

- [Tailscale 公式ドキュメント](https://tailscale.com/kb/)
- [OpenClaw GitHub](https://github.com/openclaw/openclaw)
- [OpenClaw ドキュメント](https://docs.openclaw.ai)
