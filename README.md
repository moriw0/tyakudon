## 🍜 ちゃくどんとは?
ラーメン待ち時間計測・シェアWebアプリです。

🔗 https://tyakudon.com

アプリ紹介ビデオはこちら

🔗 https://youtu.be/HobXb57a8OI?si=PGUnzGXE-uVDIcGU


## 🔧 用途
* ラーメン店に並ぶ（接続）〜ラーメンが提供される（着丼）までの待ち時間を計測
* 記録された待ち時間である「ちゃくどんレコード」の閲覧

|待ち時間計測|ちゃくどんレコードの閲覧|
|---|---|
|<img src="docs/images/measure.gif" alt="attach:cat" title="attach:cat" width="300">|<img src="docs/images/line_status.gif" alt="attach:cat" title="attach:cat" width="300">|

## 技術スタック

Ruby 3.3.8 / Rails 7.1 / PostgreSQL 16 / Bootstrap / Hotwire (Turbo + Stimulus)

## 本番環境

- ホスティング: [Fly.io](https://fly.io)
- CI: PR作成時に RSpec テストと RuboCop が実行される
- デプロイ: `main` ブランチへのマージで GitHub Actions により自動デプロイ

## 環境構築について
### セットアップ手順
```bash
# 1. リポジトリをクローン
git clone https://github.com/moriw0/tyakudon.git
cd tyakudon

# 2. Docker イメージをビルド
docker compose build

# 3. コンテナを起動
docker compose up -d

# 4. データベースのセットアップ（作成・マイグレーション・シード）
docker compose exec app bundle exec rails db:prepare
```

完了後 http://localhost:3000 でアクセスできます。

### よく使うコマンド

```bash
docker compose up -d           # コンテナ起動（バックグラウンド）
docker compose down            # コンテナ停止
docker compose exec app bundle exec rspec           # テスト実行
docker compose exec app bundle exec rails c         # Rails コンソール
docker compose exec app bash                        # コンテナ内シェル
docker compose exec app bundle exec rails db:migrate  # マイグレーション実行
```

※ `Makefile` にショートカットが定義されています（`make up`, `make rspec` など）

### Dev Containers (準備中)
VS Code や JetBrains IDE で Dev Containers を利用できます。
コンテナ内では Claude Code がインストール済みのため、`claude` コマンドが利用可能です。

1. リポジトリをクローンして IDE で開く
2. 「Dev Containers で再度開く」を選択
3. 初回起動時に `bin/setup` が自動実行され、DBセットアップが完了
4. `bin/dev` でサーバーを起動 → http://localhost:3000
