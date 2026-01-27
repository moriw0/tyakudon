# リポジトリ構造定義書 (Repository Structure Document)

## プロジェクト構造

```
tyakudon/
├── app/                       # アプリケーションコード
│   ├── assets/                # 静的ファイル（CSS、画像）
│   ├── controllers/           # コントローラー（22 controllers）
│   ├── helpers/               # ビューヘルパー
│   ├── javascript/            # Stimulus controllers
│   ├── jobs/                  # バックグラウンドジョブ（2 jobs）
│   ├── mailers/               # メーラー
│   ├── models/                # モデル（10 models）
│   ├── services/              # サービスオブジェクト（6 services）
│   └── views/                 # ビューテンプレート（ERB）
├── bin/                       # 実行可能スクリプト
├── config/                    # 設定ファイル
│   ├── environments/          # 環境別設定
│   ├── initializers/          # 初期化設定
│   ├── locales/               # 国際化ファイル
│   ├── credentials.yml.enc    # 暗号化された秘密情報
│   ├── database.yml           # データベース設定
│   └── routes.rb              # ルーティング設定
├── db/                        # データベース関連
│   ├── fixtures/development/  # 開発環境用サンプルデータ
│   ├── migrate/               # マイグレーションファイル
│   ├── schema.rb              # スキーマ定義
│   └── seeds.rb               # シードデータ
├── docs/                      # プロジェクトドキュメント（永続的）
│   ├── ideas/                 # アイデア・下書き
│   ├── product-requirements.md
│   ├── functional-design.md
│   ├── architecture.md
│   ├── development-guidelines.md
│   ├── repository-structure.md
│   └── glossary.md
├── .steering/                 # 作業単位のドキュメント
│   └── YYYYMMDD-task-name/
│       ├── requirements.md
│       ├── design.md
│       └── tasklist.md
├── lib/                       # ライブラリコード
├── public/                    # 静的ファイル（Webサーバー直接配信）
├── spec/                      # RSpecテスト
│   ├── factories/             # FactoryBot定義
│   ├── jobs/                  # ジョブテスト
│   ├── models/                # モデルテスト
│   ├── requests/              # リクエストテスト
│   ├── services/              # サービステスト
│   └── system/                # システムテスト（E2E）
├── storage/                   # Active Storage（開発環境）
├── tmp/                       # 一時ファイル
├── vendor/                    # サードパーティコード
├── .gitignore                 # Git除外設定
├── .rubocop.yml               # RuboCop設定
├── CLAUDE.md                  # Claude Code向け開発ガイド
├── docker-compose.yml         # Docker Compose設定
├── Dockerfile                 # Dockerイメージ定義
├── Gemfile                    # Gem依存関係
├── Gemfile.lock               # Gemバージョン固定
├── Makefile                   # ショートカットコマンド
└── README.md                  # プロジェクト概要
```

## ディレクトリ詳細

### app/ (アプリケーションコード)

#### app/controllers/

**役割**: HTTPリクエストの処理、パラメータ検証、レスポンス生成

**ファイル数**: 19 controllers (application_controllerを含む)

**主要ファイル**:
```
app/controllers/
├── application_controller.rb          # 基底コントローラー
├── records_controller.rb               # 待ち時間記録
├── ramen_shops_controller.rb           # ラーメン店舗
├── line_statuses_controller.rb         # 行列状況
├── favorites_controller.rb             # お気に入り
├── likes_controller.rb                 # いいね
├── sessions_controller.rb              # ログイン/ログアウト
├── users_controller.rb                 # ユーザー登録
├── omniauth_users_controller.rb        # OAuth認証
├── cheer_messages_controller.rb        # 応援メッセージ
├── faqs_controller.rb                  # FAQ
└── shop_register_requests_controller.rb # 店舗登録リクエスト
```

**命名規則**:
- ファイル名: `[リソース名（複数形)]_controller.rb`（snake_case）
- クラス名: `[リソース名（複数形）]Controller`（PascalCase）

**依存関係**:
- 依存可能: `models/`, `services/`, `helpers/`
- 依存禁止: 他のコントローラー、外部API直接呼び出し

#### app/models/

**役割**: すべてのアプリケーションロジックを配置（ActiveRecord、Concerns、PORO）

**3種類のクラス構成**:
1. **ActiveRecord**: DBテーブルに紐づくモデル
2. **Concerns**: 共有する振る舞い（`concerns/` 配下）
3. **PORO**: 単独のロジック（将来的な外部クライアント等）

**主要ファイル**:
```
app/models/
├── concerns/                   # 共有する振る舞い
│   ├── retirable.rb
│   └── geocodable.rb
├── application_record.rb      # 基底モデル
├── user.rb                     # ActiveRecord: ユーザー
├── record.rb                   # ActiveRecord: 待ち時間記録
├── ramen_shop.rb               # ActiveRecord: ラーメン店舗
├── line_status.rb              # ActiveRecord: 行列状況
├── cheer_message.rb            # ActiveRecord: 応援メッセージ
├── favorite.rb                 # ActiveRecord: お気に入り
├── like.rb                     # ActiveRecord: いいね
├── faq.rb                      # ActiveRecord: FAQ
├── shop_register_request.rb    # ActiveRecord: 店舗登録リクエスト
└── (future) document_fetcher.rb  # PORO: 外部クライアント（将来的）
```

**命名規則**:
- ファイル名: `[モデル名（単数形）].rb`（snake_case）
- クラス名: `[モデル名（単数形）]`（PascalCase）
- テーブル名: `[モデル名（複数形）]`（snake_case、Railsが自動変換）

**依存関係**:
- 依存可能: 他のModels、`concerns/`、外部API（PORO経由）
- 依存禁止: `controllers/`

#### app/models/concerns/

**現状**: このディレクトリは現在空です（.keepファイルのみ）

**実装状況**: 未実装

**将来的な実装**:

**役割**: モデル間で共通する振る舞いの共有、ビジネスロジックの整理

**配置ルール**: `app/models/concerns/`

**命名規則**:
- ファイル名: `[concern名].rb`（snake_case）
- モジュール名: `[Concern名]`（PascalCase）
- 形容詞形（-able）または機能名を使用

**将来的な実装候補例**:
```
app/models/concerns/
├── geocodable.rb              # 位置情報取得の振る舞い
├── likeable.rb                # いいね機能の振る舞い
├── retirable.rb               # 終了処理の振る舞い
└── searchable.rb              # 検索機能の振る舞い
```

**実装例**:
```ruby
# app/models/concerns/retirable.rb （実装例）
module Retirable
  extend ActiveSupport::Concern

  included do
    scope :active, -> { where(ended_at: nil, is_retired: false) }
  end

  def retire!
    update(is_retired: true, ended_at: Time.current)
  end
end

# app/models/record.rb
class Record < ApplicationRecord
  include Retirable
end
```

**依存関係**:
- 依存可能: 他のConcerns
- 依存禁止: `controllers/`、`services/`、外部API直接呼び出し

#### app/services/（非推奨）

**現状**: 6つのファイルが存在し、`lib/tasks/scraping.thor` で使用されています（スクレイピングタスク用）。

**方針**: スクレイピングワークフロー専用として維持。新規ビジネスロジックは `app/models/` に配置してください。

**現状**: 以下の6ファイルが存在しますが、**現在どこからも使用されていません**。

**代替案**: 外部API連携やHTTPクライアントは、`app/models/` 配下にPOROとして実装してください。

#### app/jobs/

**役割**: バックグラウンドジョブ、非同期処理

**主要ファイル**:
```
app/jobs/
├── application_job.rb          # 基底ジョブ
├── auto_retire_record_job.rb   # レコード自動終了
└── speak_cheer_message_job.rb  # 応援メッセージ生成
```

**命名規則**:
- ファイル名: `[目的]_job.rb`（snake_case）
- クラス名: `[目的]Job`（PascalCase）

**依存関係**:
- 依存可能: `models/`, `services/`
- 依存禁止: `controllers/`、`views/`

#### app/views/

**役割**: HTMLテンプレート、ユーザーインターフェース

**構造**:
```
app/views/
├── layouts/
│   ├── application.html.erb    # メインレイアウト
│   └── mailer.html.erb         # メールレイアウト
├── records/
│   ├── index.html.erb          # 一覧
│   ├── show.html.erb           # 詳細
│   ├── new.html.erb            # 新規作成フォーム
│   └── edit.html.erb           # 編集フォーム
├── ramen_shops/
│   ├── index.html.erb
│   └── show.html.erb
└── shared/
    ├── _header.html.erb        # ヘッダー
    └── _footer.html.erb        # フッター
```

**命名規則**:
- ディレクトリ名: コントローラー名と一致（複数形、snake_case）
- ファイル名: アクション名 + `.html.erb`
- パーシャル: `_[名前].html.erb`（アンダースコアで始まる）

#### app/javascript/

**役割**: Stimulus controllers、JavaScriptコード

**構造**:
```
app/javascript/
├── controllers/
│   ├── application.js          # Stimulus application
│   └── hello_controller.js     # サンプルコントローラー
└── application.js              # エントリーポイント
```

#### app/assets/

**役割**: CSS、画像などの静的ファイル

**構造**:
```
app/assets/
├── stylesheets/
│   └── application.css         # メインCSS
└── images/
    └── logo.png
```

### config/ (設定ファイル)

#### config/routes.rb

**役割**: ルーティング定義

**例**:
```ruby
Rails.application.routes.draw do
  root 'static_pages#home'

  resources :records
  resources :ramen_shops, only: [:index, :show]
  resources :line_statuses, only: [:create, :update, :destroy]
  resources :favorites, only: [:create, :destroy, :index]
  resources :likes, only: [:create, :destroy]

  # 認証
  get '/signup', to: 'users#new'
  post '/signup', to: 'users#create'
  get '/login', to: 'sessions#new'
  post '/login', to: 'sessions#create'
  delete '/logout', to: 'sessions#destroy'

  # OAuth
  get '/auth/google_oauth2/callback', to: 'omniauth_users#create'
end
```

#### config/database.yml

**役割**: データベース接続設定

**例**:
```yaml
default: &default
  adapter: postgresql
  encoding: unicode
  pool: <%= ENV.fetch("RAILS_MAX_THREADS") { 5 } %>

development:
  <<: *default
  database: tyakudon_development

test:
  <<: *default
  database: tyakudon_test

production:
  <<: *default
  url: <%= ENV['DATABASE_URL'] %>
```

#### config/credentials.yml.enc

**役割**: 暗号化された秘密情報（API key、パスワードなど）

**編集**:
```bash
EDITOR=vim rails credentials:edit
```

**内容例**:
```yaml
gcp:
  client_id: xxx
  client_secret: xxx

openai:
  secret_key: xxx

aws:
  access_key_id: xxx
  secret_access_key: xxx
```

### db/ (データベース関連)

#### db/migrate/

**役割**: データベースマイグレーションファイル

**命名規則**:
```
YYYYMMDDHHMMSS_create_users.rb
YYYYMMDDHHMMSS_add_index_to_users_email.rb
```

**例**:
```ruby
# 20240101120000_create_users.rb
class CreateUsers < ActiveRecord::Migration[7.0]
  def change
    create_table :users do |t|
      t.string :name
      t.string :email, null: false
      t.string :password_digest

      t.timestamps
    end

    add_index :users, :email, unique: true
  end
end
```

#### db/schema.rb

**役割**: データベースの現在のスキーマ定義（自動生成）

**注意**: 手動編集禁止（マイグレーションで変更）

#### db/seeds.rb

**役割**: 初期データ投入

**例**:
```ruby
# 開発環境用サンプルデータ
if Rails.env.development?
  User.create!(
    name: 'テストユーザー',
    email: 'test@example.com',
    password: 'password',
    activated: true
  )

  RamenShop.create!(
    name: 'ラーメン二郎',
    address: '東京都港区三田2-16-4',
    latitude: 35.6432,
    longitude: 139.7390
  )
end
```

#### db/fixtures/development/

**役割**: 開発環境用の充実したサンプルデータ

**使用**:
```bash
docker compose exec app rails db:fixtures:load
```

### spec/ (RSpecテスト)

#### spec/models/

**役割**: モデルテスト

**命名規則**: `[モデル名]_spec.rb`

**例**:
```ruby
# spec/models/user_spec.rb
RSpec.describe User, type: :model do
  it { should have_many(:records) }
  it { should validate_presence_of(:email) }
end
```

#### spec/requests/

**役割**: コントローラーテスト（リクエスト/レスポンス）

**命名規則**: `[コントローラー名]_spec.rb`

**例**:
```ruby
# spec/requests/records_spec.rb
RSpec.describe 'Records', type: :request do
  describe 'GET /records' do
    it 'returns http success'
  end
end
```

#### spec/system/

**役割**: E2Eテスト（ブラウザ操作）

**命名規則**: `[機能名]_spec.rb`

**例**:
```ruby
# spec/system/user_login_spec.rb
RSpec.describe 'User login', type: :system do
  it 'ユーザーがログインできる'
end
```

#### spec/factories/

**役割**: FactoryBotのファクトリ定義

**命名規則**: `[モデル名（複数形）].rb`

**例**:
```ruby
# spec/factories/users.rb
FactoryBot.define do
  factory :user do
    sequence(:email) { |n| "user#{n}@example.com" }
    password { 'password' }
  end
end
```

### docs/ (プロジェクトドキュメント - 永続的)

**役割**: プロジェクト全体の設計・仕様を定義

**主要ファイル**:
```
docs/
├── ideas/                          # アイデア・下書き
│   └── feature-brainstorm.md
├── product-requirements.md         # プロダクト要求定義書
├── functional-design.md            # 機能設計書
├── architecture.md                 # 技術仕様書
├── development-guidelines.md       # 開発ガイドライン
├── repository-structure.md         # リポジトリ構造定義書（このファイル）
└── glossary.md                     # ユビキタス言語定義
```

**更新頻度**: 低い（基本設計が変わるとき）

### .steering/ (作業単位のドキュメント - 一時的)

**役割**: 特定の開発作業における計画・設計を定義

**構造**:
```
.steering/
├── 20250125-add-review-feature/
│   ├── requirements.md         # 今回の要求内容
│   ├── design.md               # 実装アプローチ
│   └── tasklist.md             # タスクリスト
└── 20250120-fix-geocoder-timeout/
    ├── requirements.md
    ├── design.md
    └── tasklist.md
```

**命名規則**: `YYYYMMDD-[タスク名]`

**更新頻度**: 高い（作業ごとに新規作成）

### 特殊ディレクトリ

#### storage/

**役割**: Active Storageのローカルストレージ（開発環境）

**注意**: `.gitignore`で除外

#### tmp/

**役割**: 一時ファイル（キャッシュ、pid、sockets）

**注意**: `.gitignore`で除外

#### vendor/

**役割**: サードパーティのコード（Gemを除く）

## ファイル配置ルール

### 新しいモデルを追加する場合

1. **マイグレーション作成**:
   ```bash
   docker compose exec app rails generate model Review user:references ramen_shop:references rating:integer comment:text
   ```

2. **ファイル生成確認**:
   - `app/models/review.rb`
   - `db/migrate/YYYYMMDDHHMMSS_create_reviews.rb`
   - `spec/models/review_spec.rb`
   - `spec/factories/reviews.rb`

3. **マイグレーション実行**:
   ```bash
   docker compose exec app rails db:migrate
   ```

### 新しいコントローラーを追加する場合

1. **コントローラー作成**:
   ```bash
   docker compose exec app rails generate controller Reviews index show new create
   ```

2. **ファイル生成確認**:
   - `app/controllers/reviews_controller.rb`
   - `app/views/reviews/index.html.erb`
   - `app/views/reviews/show.html.erb`
   - `app/views/reviews/new.html.erb`
   - `spec/requests/reviews_spec.rb`

3. **ルーティング追加**:
   ```ruby
   # config/routes.rb
   resources :reviews
   ```

### 新しいサービスを追加する場合

1. **手動でファイル作成**:
   ```bash
   touch app/services/review_analyzer.rb
   ```

2. **クラス定義**:
   ```ruby
   # app/services/review_analyzer.rb
   class ReviewAnalyzer
     def initialize(review)
       @review = review
     end

     def analyze
       # ロジック
     end
   end
   ```

3. **テスト作成**:
   ```bash
   touch spec/services/review_analyzer_spec.rb
   ```

### 新しいジョブを追加する場合

1. **ジョブ作成**:
   ```bash
   docker compose exec app rails generate job SendReviewNotification
   ```

2. **ファイル生成確認**:
   - `app/jobs/send_review_notification_job.rb`
   - `spec/jobs/send_review_notification_job_spec.rb`

## 依存関係のルール

### 許可される依存関係

```
Controllers → Models, Concerns, Helpers
Jobs → Models, Concerns
Models → Concerns, 他のModels, 外部API（PORO経由）
Views → Helpers
```

### 禁止される依存関係

```
Models → Controllers, Jobs
Concerns → Controllers, Jobs
Views → Controllers, Models（直接）
```

### 循環依存の回避

**Bad**:
```ruby
# app/services/user_service.rb
class UserService
  def create_record
    RecordService.new.create  # ❌
  end
end

# app/services/record_service.rb
class RecordService
  def notify_user
    UserService.new.notify  # ❌ 循環依存
  end
end
```

**Good**:
```ruby
# app/services/user_service.rb
class UserService
  def create_record
    Record.create(...)  # ✅ モデルを直接使用
  end
end

# app/services/record_service.rb
class RecordService
  def notify_user
    User.find(...).notify  # ✅ モデルを直接使用
  end
end
```

## スケーリング戦略

### モデルが多くなった場合

**Concerns の作成基準**:
- 複数のモデルで共通する振る舞い
- モデルが200行を超えたら分割を検討
- 明確な責務単位（位置情報、いいね、検索など）

**ディレクトリで整理**:
```
app/models/
├── concerns/                   # 共通モジュール（推奨パターン）
│   ├── geocodable.rb
│   ├── likeable.rb
│   ├── retirable.rb
│   └── searchable.rb
├── records/                    # Recordモデル関連
│   ├── record.rb
│   └── line_status.rb
├── users/                      # Userモデル関連
│   ├── user.rb
│   └── favorite.rb
└── application_record.rb
```

## 除外設定（.gitignore）

**主要な除外ファイル**:
```
# 秘密情報
/config/master.key
.env

# 一時ファイル
/tmp/*
/storage/*
/public/packs
/public/assets

# ログ
/log/*.log

# テストカバレッジ
/coverage

# macOS
.DS_Store

# IDEs
/.idea
/.vscode
```

## まとめ

このドキュメントでは、ちゃくどんプロジェクトのリポジトリ構造を定義しました。

**重要なポイント**:
- Rails標準のディレクトリ構造に従う
- `app/`配下の役割を理解する（controllers, models, services, jobs, views）
- `docs/`は永続的なドキュメント、`.steering/`は作業単位のドキュメント
- 依存関係のルールを守る（Controllers → Services → Models）
- スケーリング時はディレクトリで整理

**参考資料**:
- [Rails Guides - Getting Started](https://guides.rubyonrails.org/getting_started.html)
- [Rails Directory Structure](https://www.rubyguides.com/2020/03/rails-directory-structure/)
