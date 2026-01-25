# CLAUDE.md

Claude Code 向けの開発ガイドです。環境構築手順は [README.md](./README.md) を参照してください。

## Development Commands

開発は Docker Compose で行います。アプリは port 3000 で起動します。

```bash
# テスト
docker compose exec app bundle exec rspec                              # 全テスト
docker compose exec app bundle exec rspec spec/models/user_spec.rb     # ファイル指定
docker compose exec app bundle exec rspec spec/models/user_spec.rb:7   # 行指定

# Lint
docker compose exec app bundle exec rubocop
docker compose exec app bundle exec rubocop -a   # 自動修正
```

※ `Makefile` にショートカットあり（`make rspec`, `make db-migrate` など）

## Architecture

### Key Models
- `User` - パスワード認証 or Google OAuth2
- `Record` - 待ち時間記録（User と RamenShop を紐付け）
- `RamenShop` - 店舗情報（Geocoder で座標管理）
- `LineStatus` - 待ち中の行列状況
- `Favorite` / `Like` - お気に入り・いいね機能

### Services (`app/services/`)
- `DocumentFetcher` - Webスクレイピング
- `ShopInfoExtractor` / `ShopInfoInserter` - 店舗データの抽出・登録
- `GoogleSpreadSheet` - スクレイピングワークフロー用

### Background Jobs (GoodJob)
- `AutoRetireRecordJob` - 1日経過した記録を自動終了
- `SpeakCheerMessageJob` - OpenAI で応援メッセージ生成

### External Integrations
- Google OAuth2 - 認証
- OpenAI API - 応援メッセージ生成
- Geocoder - 位置情報
- Active Storage + S3 (本番) - ファイルアップロード

## Code Style

RuboCop 設定 (`.rubocop.yml`):
- Ruby 1.9+ ハッシュ記法
- Lambda は `->` を使用
- RSpec: `to_not` スタイル
- RSpec context: when, with, without, if, unless, for, before, after, during
- ブロック: `braces_for_chaining`

## Credentials

Rails credentials (`rails credentials:edit`):
- `gcp.client_id` / `gcp.client_secret` - Google OAuth
- `openai.secret_key` - OpenAI API
