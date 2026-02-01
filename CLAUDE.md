## Project Overview

**プロジェクト名:** tyakudon (ちゃくどん)

**概要:** ラーメン店の待ち時間を記録・共有するWebアプリケーション。ユーザーは店舗の待ち時間を投稿し、他のユーザーと共有できます。OpenAI を活用した応援メッセージ機能も提供しています。

**技術スタック:**

- Ruby on Rails 7.0
- PostgreSQL
- GoodJob (バックグラウンドジョブ)
- Hotwire (Turbo + Stimulus)
- Docker Compose (開発環境)
- Fly.io (本番環境)

**主要機能:**

- 待ち時間記録の投稿・閲覧
- 店舗情報の管理（Geocoder による位置情報）
- いいね・お気に入り機能
- OpenAI による応援メッセージ生成
- Google OAuth2 認証
- Webスクレイピングによる店舗データ自動取得

## Critical Rules

### Code Organization

- 多数の小さいファイルを、少数の大きいファイルよりも優先
- 高凝集・低結合を意識
- ドメイン/機能単位で整理
- ビジネスロジックはモデル app/models/ に配置
    1. ActiveRecord: DBテーブルに紐づくモデル
    2. Concerns: 共有する振る舞いや、機能をまとめたモジュール
    3. PORO: それ以外の単独ロジック
- app/services/ は非推奨 (既存ファイルはモデルに移行予定で、新規実装では使わない)

### Code Style

- 可能な限り不変性を保つ（オブジェクトや配列を変更しない）
- 本番環境に `puts` や `p` を残さない
- `rescue` で適切にエラーを処理する
- バリデーションはモデルに集約する

### Testing

- TDD: まずテストを書いてから実装
- カバレッジ: 80%以上
- Unit tests: モデル、ユーティリティ
- Integration tests: API エンドポイント、コントローラー (RequestSpec)
- E2E tests: 重要なユーザーフローに適用 (Capybara)

### Security

- シークレットは Rails credentials または `.env` で管理
- 全てのユーザー入力をバリデーションする
- SQL インジェクション防止（受付はパラメータ化クエリのみ）
- XSS 防止（HTML サニタイズ）
- 認証・認可を確認

## Git Workflow

- Conventional commits: `feat:`, `fix:`, `refactor:`, `docs:`, `test:`
- Never commit to main directly
- PRs require review
- All tests must pass before merge
