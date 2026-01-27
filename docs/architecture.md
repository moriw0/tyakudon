# 技術仕様書 (Architecture Design Document)

## テクノロジースタック

### 言語・フレームワーク

| 技術 | バージョン | 選定理由 |
|------|-----------|----------|
| Ruby | 3.2.2 | 安定版、Railsとの親和性が高い、豊富なgemエコシステム |
| Ruby on Rails | 7.0 | モダンな機能（Hotwire統合）、Active Record ORM、セキュリティ機能ビルトイン |

### データベース

| 技術 | バージョン | 選定理由 |
|------|-----------|----------|
| PostgreSQL | 14 | リレーショナルDB、GIS拡張（Geocoder対応）、Fly.io/Heroku対応、信頼性が高い |

### フロントエンド

| 技術 | バージョン | 用途 | 選定理由 |
|------|-----------|------|----------|
| Bootstrap | 5.x | CSSフレームワーク | レスポンシブデザイン、プロトタイプ高速化、豊富なコンポーネント |
| Hotwire (Turbo + Stimulus) | 最新 | フロントエンドフレームワーク | SPA的UXをサーバーサイドレンダリングで実現、JavaScriptコード量削減 |
| ERB | Rails標準 | テンプレートエンジン | Railsビルトイン、学習コスト低い |

### バックグラウンドジョブ

| 技術 | バージョン | 用途 | 選定理由 |
|------|-----------|------|----------|
| GoodJob | 最新 | バックグラウンドジョブ処理 | PostgreSQLベース、Redis不要、シンプル、管理画面あり |

### 外部サービス統合

| 技術 | バージョン | 用途 | 選定理由 |
|------|-----------|------|----------|
| omniauth-google-oauth2 | 最新 | Google OAuth2認証 | Google認証統合、セキュア、ユーザー体験向上 |
| geocoder | 最新 | 位置情報取得 | 住所→緯度経度変換、複数プロバイダー対応 |
| ruby-openai | 最新 | OpenAI API統合 | 応援メッセージ生成、簡単なAPI操作 |
| aws-sdk-s3 | 最新 | ファイルストレージ | Active Storage + S3統合（本番環境） |

### 開発ツール

| 技術 | バージョン | 用途 | 選定理由 |
|------|-----------|------|----------|
| RSpec | 最新 | テストフレームワーク | Rails標準、BDD、豊富なマッチャー |
| FactoryBot | 最新 | テストデータ生成 | RSpecとの親和性、柔軟なデータ生成 |
| RuboCop | 最新 | Linter | コード品質管理、スタイル統一 |
| Bullet | 最新 | N+1問題検出 | 開発環境でパフォーマンス問題を早期発見 |

### インフラ・デプロイ

| 技術 | 用途 | 選定理由 |
|------|------|----------|
| Fly.io | ホスティング | PostgreSQL統合、簡単なデプロイ、無料枠あり |
| GitHub Actions | CI/CD | RSpec + RuboCop自動実行、main mergeで自動デプロイ |
| AWS S3 | ファイルストレージ | Active Storage統合、本番環境での画像保存 |

## アーキテクチャパターン

### Rails MVC + Models中心パターン

**基本設計方針**:
- **すべてのロジックはapp/models/に配置**: Railsの思想 "Fat Model, Skinny Controller" に従う
- **app/models/の3分類**:
  1. **ActiveRecord**: DBテーブルに紐づくモデル (user.rb, record.rb等)
  2. **Concerns**: 共有する振る舞い (concerns/retirable.rb等)
  3. **PORO**: 単独のロジック (将来的な外部クライアント等)
- **app/services/は非推奨**: 既存ファイルは参考用として残すが、新規実装では使用しない

```
┌─────────────────────────────────────────────────────┐
│   Presentation Layer (Views + Hotwire)               │
│   ← ERB templates, Stimulus controllers             │
├─────────────────────────────────────────────────────┤
│   Application Layer (Controllers)                   │
│   ← Request handling, params validation             │
├─────────────────────────────────────────────────────┤
│   Business Logic Layer (Models + Concerns)          │
│   ← ActiveRecord, Concerns, PORO                    │
│   ← Domain logic, validations, shared behaviors     │
├─────────────────────────────────────────────────────┤
│   Data Layer (ActiveRecord + PostgreSQL)            │
│   ← Persistence, queries, transactions              │
└─────────────────────────────────────────────────────┘

         ┌────────────────────────────┐
         │  Background Jobs (GoodJob) │
         │  ← Async processing         │
         └────────────────────────────┘
```

#### Presentation Layer（Viewレイヤー）

- **責務**: ユーザーインターフェースの表示、HTMLレンダリング
- **技術**: ERB templates, Bootstrap, Hotwire (Turbo + Stimulus)
- **許可される操作**: Controllerから受け取ったデータの表示
- **禁止される操作**: ビジネスロジックの実装、直接的なDB操作

**例**:
```erb
<!-- app/views/records/show.html.erb -->
<h1><%= @record.ramen_shop.name %></h1>
<p>待ち時間: <%= (@record.wait_time / 60).floor %> 分</p>
```

#### Application Layer（Controllerレイヤー）

- **責務**: HTTPリクエストの処理、パラメータ検証、レスポンス生成
- **技術**: Rails Controllers
- **許可される操作**: Services/Modelsの呼び出し、Viewへのデータ渡し
- **禁止される操作**: 複雑なビジネスロジックの実装、外部API直接呼び出し

**例**:
```ruby
# app/controllers/records_controller.rb
class RecordsController < ApplicationController
  def create
    @record = current_user.records.build(record_params)
    @record.started_at = Time.current

    if @record.save
      redirect_to @record, notice: '計測を開始しました'
    else
      render :new
    end
  end

  private

  def record_params
    params.require(:record).permit(:ramen_shop_id, :comment)
  end
end
```

#### Business Logic Layer（Services + Modelsレイヤー）

**Models（ActiveRecord）**:
- **責務**: データ検証、関連付け、シンプルなビジネスロジック
- **技術**: ActiveRecord
- **許可される操作**: DB操作、バリデーション、コールバック
- **禁止される操作**: 外部API呼び出し、複雑なワークフロー

**例**:
```ruby
# app/models/record.rb
class Record < ApplicationRecord
  belongs_to :user
  belongs_to :ramen_shop

  validates :user_id, presence: true
  validates :ramen_shop_id, presence: true

  before_save :calculate_wait_time

  private

  def calculate_wait_time
    if started_at.present? && ended_at.present?
      self.wait_time = (ended_at - started_at)  # 秒単位で保存
    end
  end
end
```

**Services（非推奨）**:
⚠️ **非推奨**: 今後は `app/models/` を使用してください。
- **現状**: ファイルが存在し、`lib/tasks/scraping.thor` で使用されています（スクレイピングタスク用）。
- **方針**: スクレイピングワークフロー専用として維持。新規ビジネスロジックは `app/models/` を使用してください

**Concerns（ActiveSupport::Concern）**:

**現状**: `app/models/concerns/` ディレクトリは現在空です（.keepファイルのみ）
**将来的な実装例**:
- **責務**: モデル間で共通する振る舞いの共有、ビジネスロジックの整理
- **技術**: ActiveSupport::Concern
- **配置**: app/models/concerns/
- **許可される操作**: モデルメソッド定義、バリデーション、コールバック
- **禁止される操作**: 外部API呼び出し

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
```

#### Data Layer（ActiveRecord + PostgreSQL）

- **責務**: データ永続化、クエリ実行、トランザクション管理
- **技術**: ActiveRecord ORM, PostgreSQL
- **許可される操作**: SQL実行、データ取得・保存
- **禁止される操作**: ビジネスロジックの実装

**例**:
```ruby
# ActiveRecordが生成するSQL
Record.includes(:user, :ramen_shop).where(ended_at: nil)
# => SELECT * FROM records LEFT JOIN users ON ... LEFT JOIN ramen_shops ON ... WHERE ended_at IS NULL
```

#### Background Jobs Layer（GoodJob）

- **責務**: 非同期処理、定期実行タスク
- **技術**: GoodJob (ActiveJob backend)
- **トリガー**: Controller、Model callback、Cron

**例**:
```ruby
# app/jobs/auto_retire_record_job.rb
class AutoRetireRecordJob < ApplicationJob
  queue_as :default

  def perform
    Record.where('started_at < ? AND ended_at IS NULL', 1.day.ago).find_each do |record|
      record.update(auto_retired: true, ended_at: record.started_at + 1.day)
    end
  end
end
```

### 依存関係のルール

```
┌─────────────┐
│ Controllers │──┐
└─────────────┘  │
                 ├──→ ┌────────┐
┌─────────────┐  │    │ Models │ ←─ ┌──────────┐
│    Views    │──┘    └────────┘    │ Concerns │
└─────────────┘            │         └──────────┘
                           │              │
┌─────────────┐            │              │
│    Jobs     │────────────┴──────────────┘
└─────────────┘                      │
                                     ↓
                              ┌──────────────┐
                              │  PostgreSQL  │
                              └──────────────┘
```

- **Controllers** → Models, Concerns
- **Views** → データ表示のみ（ビジネスロジックなし）
- **Jobs** → Models, Concerns
- **Models** → Concerns, 他のModels
- **Concerns** → PostgreSQL（モデル層の責務）

## データ永続化戦略

### ストレージ方式

| データ種別 | ストレージ | 理由 |
|-----------|----------|------|
| ユーザーデータ、レコード、店舗情報 | PostgreSQL | リレーショナルデータ、トランザクション保証、複雑なクエリ対応 |
| 画像ファイル | Active Storage + S3 (本番) / Local (開発) | スケーラブル、CDN統合可能、Railsビルトイン |
| バックグラウンドジョブキュー | PostgreSQL (GoodJob) | Redis不要、シンプル、既存DBを活用 |

### データベース設計

**主要テーブル**:
- `users` - ユーザー情報
- `ramen_shops` - ラーメン店舗情報
- `records` - 待ち時間記録
- `line_statuses` - 行列状況
- `cheer_messages` - 応援メッセージ
- `favorites` - お気に入り
- `likes` - いいね
- `faqs` - よくある質問
- `shop_register_requests` - 店舗登録リクエスト

**インデックス戦略**:
```sql
-- 頻繁に検索されるカラム
CREATE INDEX index_users_on_email ON users(email);
CREATE UNIQUE INDEX index_users_on_uid_and_provider ON users(uid, provider);

-- 外部キー
CREATE INDEX index_records_on_user_id ON records(user_id);
CREATE INDEX index_records_on_ramen_shop_id ON records(ramen_shop_id);

-- 複合インデックス（ソート・絞り込み）
CREATE INDEX index_records_on_user_id_and_created_at ON records(user_id, created_at);

-- ユニーク制約
CREATE UNIQUE INDEX index_ramen_shops_on_name_and_address ON ramen_shops(name, address);
CREATE UNIQUE INDEX index_favorites_on_user_id_and_ramen_shop_id ON favorites(user_id, ramen_shop_id);
CREATE UNIQUE INDEX index_likes_on_user_id_and_record_id ON likes(user_id, record_id);
```

### バックアップ戦略

**Fly.io自動バックアップ**:
- 頻度: 毎日自動
- 保持期間: 7日間（Free tier）
- 復元方法: Fly.io CLIコマンド

**手動バックアップ**:
```bash
# PostgreSQLダンプ
pg_dump -h <host> -U <user> -d tyakudon_production > backup.sql

# 復元
psql -h <host> -U <user> -d tyakudon_production < backup.sql
```

## パフォーマンス要件

### レスポンスタイム

| 操作 | 目標時間 (P95) | 測定環境 |
|------|---------------|---------|
| トップページ表示 | 500ms以内 | Fly.io (Free tier) |
| レコード一覧（20件） | 300ms以内 | 同上 |
| レコード作成 | 1秒以内 | 同上 |
| 店舗検索 | 500ms以内 | 同上 |

### スループット

| 指標 | 目標値 |
|------|-------|
| 同時接続ユーザー | 100人 |
| 1秒あたりのリクエスト数 | 10 req/sec |

### データベースパフォーマンス

**N+1問題の回避**:
```ruby
# Bad: N+1問題
@records = Record.all
@records.each do |record|
  puts record.user.name       # N回のクエリ
  puts record.ramen_shop.name # N回のクエリ
end

# Good: Eager loading
@records = Record.includes(:user, :ramen_shop).all
# => 3回のクエリ（records, users, ramen_shops）
```

**Bullet gemによる検出**:
- 開発環境で自動的にN+1問題を検出
- ブラウザに警告を表示
- ログに記録

**クエリ最適化**:
```ruby
# インデックスを活用したクエリ
Record.where(user_id: current_user.id).order(created_at: :desc).limit(20)
# => INDEX SCAN on index_records_on_user_id_and_created_at
```

### キャッシュ戦略

**将来的な実装（現在は未実装）**:
- **ページキャッシュ**: トップページ（5分間）
- **フラグメントキャッシュ**: 店舗統計情報（10分間）
- **Low-Level キャッシュ**: 複雑な集計クエリ結果（15分間）

**現在の方針**:
- Railsのデフォルト設定（キャッシュなし）
- Turboによる高速ページ遷移でUX向上

## セキュリティアーキテクチャ

### 認証

**パスワード認証**:
- **アルゴリズム**: bcrypt（`has_secure_password`）
- **コスト**: デフォルト（10ラウンド）
- **最小文字数**: 6文字以上

**OAuth2（Google）**:
- **gem**: omniauth-google-oauth2
- **スコープ**: email, profile
- **トークン保存**: セッション（暗号化クッキー）

**メール認証**:
- `activated` フラグで管理
- `activation_digest` トークンで検証

### 認可

**実装方式**: Controller before_action

```ruby
class RecordsController < ApplicationController
  before_action :logged_in_user, only: [:create, :update, :destroy]
  before_action :correct_user, only: [:edit, :update, :destroy]

  private

  def correct_user
    @record = current_user.records.find_by(id: params[:id])
    redirect_to root_url if @record.nil?
  end
end
```

**管理者権限**:
- `admin` フラグで管理
- ShopRegisterRequestの承認/却下権限

### CSRF対策

- **方式**: Rails標準のCSRFトークン
- **実装**: `protect_from_forgery with: :exception`
- **対象**: すべてのPOST/PATCH/PUT/DELETEリクエスト

### SQL Injection対策

- **方式**: ActiveRecord ORMによる自動エスケープ
- **禁止**: 生のSQLクエリ使用（`where("name = '#{params[:name]}'")` など）
- **推奨**: プレースホルダー使用（`where("name = ?", params[:name])`）

### XSS対策

- **方式**: ERBテンプレートの自動エスケープ
- **ヘルパー**: `sanitize`, `strip_tags`
- **Content Security Policy**: 将来的に実装検討

### パスワードリセット

- **トークン**: ランダム生成（`SecureRandom.urlsafe_base64`）
- **有効期限**: 2時間
- **保存**: `reset_digest`（ハッシュ化）

### Rails Credentials

```yaml
# config/credentials.yml.enc (暗号化)
gcp:
  client_id: xxx
  client_secret: xxx

openai:
  secret_key: xxx

aws:
  access_key_id: xxx
  secret_access_key: xxx
  region: ap-northeast-1
  bucket: tyakudon-production
```

**管理**:
```bash
# 編集
EDITOR=vim rails credentials:edit

# 確認
rails credentials:show
```

**デプロイ**:
- `config/master.key` を環境変数 `RAILS_MASTER_KEY` に設定
- Fly.io secrets: `fly secrets set RAILS_MASTER_KEY=xxx`

## スケーラビリティ設計

### 水平スケーリング

**Fly.io Multi-Region Deployment**:
```bash
# スケールアップ
fly scale count 2

# リージョン追加
fly regions add nrt  # 東京
fly regions add lax  # ロサンゼルス
```

**制約**:
- Free tier: 1インスタンスのみ
- Paid tier: 複数インスタンス対応

### データベーススケーリング

**垂直スケーリング**:
- PostgreSQLインスタンスのスペック向上
- Fly.io: `fly postgres update --vm-size shared-cpu-2x`

**水平スケーリング（将来的）**:
- Read Replica追加
- PostgreSQL 14のレプリケーション機能

### バックグラウンドジョブスケーリング

**GoodJobの並列処理**:
```ruby
# config/application.rb
config.good_job.max_threads = 5
config.good_job.poll_interval = 30 # seconds
```

**複数Workerプロセス**:
```bash
# Procfile
web: bundle exec rails server
worker: bundle exec good_job start
```

### ファイルストレージスケーリング

**Active Storage + S3**:
- S3は自動スケーリング
- CDN統合（CloudFront）で配信高速化（将来的）

## テスト戦略

### テストレベル

#### 1. Unit Tests（モデルテスト）

**対象**: Modelのバリデーション、メソッド、関連付け

**カバレッジ目標**: 90%以上

**実行時間**: 5秒以内（全テスト）

**例**:
```ruby
# spec/models/record_spec.rb
RSpec.describe Record, type: :model do
  it { should belong_to(:user) }
  it { should belong_to(:ramen_shop) }

  describe '#calculate_wait_time' do
    it '待ち時間を正しく計算する（秒単位）' do
      record = build(:record,
        started_at: Time.parse('2025-01-25 11:00:00'),
        ended_at: Time.parse('2025-01-25 11:45:00')
      )
      record.save
      expect(record.wait_time).to eq(2700)  # 45分 = 2700秒
    end
  end
end
```

#### 2. Integration Tests（リクエストテスト）

**対象**: Controller、Request/Response

**カバレッジ目標**: 80%以上

**実行時間**: 15秒以内（全テスト）

**例**:
```ruby
# spec/requests/records_spec.rb
RSpec.describe 'Records', type: :request do
  let(:user) { create(:user, activated: true) }
  let(:shop) { create(:ramen_shop) }

  describe 'POST /records' do
    it 'レコードを作成できる' do
      sign_in user
      post records_path, params: { record: { ramen_shop_id: shop.id } }

      expect(response).to have_http_status(:redirect)
      expect(Record.count).to eq(1)
    end
  end
end
```

#### 3. System Tests（E2Eテスト）

**対象**: ブラウザ操作を含む全体フロー

**カバレッジ目標**: 重要なユーザーフロー（5-10シナリオ）

**実行時間**: 30秒以内（全テスト）

**ブラウザ**: Headless Chrome

**例**:
```ruby
# spec/system/record_creation_spec.rb
RSpec.describe 'レコード作成フロー', type: :system do
  it 'ユーザーが待ち時間を記録できる' do
    user = create(:user, activated: true)
    shop = create(:ramen_shop)

    visit login_path
    fill_in 'Email', with: user.email
    fill_in 'Password', with: 'password'
    click_button 'ログイン'

    visit ramen_shop_path(shop)
    click_button '計測開始'

    expect(page).to have_content('計測中')

    click_button '着丼'

    expect(page).to have_content('待ち時間')
    expect(Record.last.ended_at).to be_present
  end
end
```

### CI/CD統合

**GitHub Actions**:
```yaml
# .github/workflows/ci.yml
name: CI

on: [pull_request]

jobs:
  test:
    runs-on: ubuntu-latest

    services:
      postgres:
        image: postgres:14
        env:
          POSTGRES_PASSWORD: postgres
        options: >-
          --health-cmd pg_isready
          --health-interval 10s

    steps:
      - uses: actions/checkout@v3
      - name: Set up Ruby
        uses: ruby/setup-ruby@v1
        with:
          ruby-version: 3.2.2
          bundler-cache: true

      - name: Run tests
        run: bundle exec rspec

      - name: Run RuboCop
        run: bundle exec rubocop
```

**マージ条件**:
- すべてのテストがパス
- RuboCopエラーなし

### テストカバレッジ

**目標**: 80%以上

**測定**: SimpleCov

```ruby
# spec/spec_helper.rb
require 'simplecov'
SimpleCov.start 'rails' do
  add_filter '/spec/'
  add_filter '/config/'
end
```

## 技術的制約

### 依存関係

**Rubyバージョン**: 3.2.2
- Gemfile.lockに記載
- Fly.ioでのビルド時に指定

**Railsバージョン**: 7.0
- Hotwire統合
- Active Storage改善

**PostgreSQLバージョン**: 14
- Geocoder拡張サポート
- Fly.ioデフォルト

### プラットフォーム制約

**Fly.io Free Tier**:
- 1インスタンス
- 256MB RAM
- 1GB PostgreSQL ストレージ
- 月間160時間稼働（1週間停止で無料枠維持）

**対応ブラウザ**:
- Chrome 最新版
- Safari 最新版
- Firefox 最新版
- モバイルブラウザ（iOS Safari、Android Chrome）

### 外部API制約

**OpenAI API**:
- レート制限: 3 req/min（Free tier）
- 対策: バックグラウンドジョブで非同期実行、リトライロジック

**Geocoder API**:
- レート制限: プロバイダーによる
- 対策: 緯度経度をDBに保存（キャッシュ）

**Google OAuth2**:
- リダイレクトURI: https://tyakudon.com/auth/google_oauth2/callback

## 依存関係管理

### Gemfile

```ruby
# Gemfile
source 'https://rubygems.org'
ruby '3.2.2'

gem 'rails', '~> 7.0'
gem 'pg', '~> 1.1'
gem 'puma', '~> 5.0'

# Frontend
gem 'turbo-rails'
gem 'stimulus-rails'
gem 'importmap-rails'
gem 'bootstrap', '~> 5.3'

# Background Jobs
gem 'good_job'

# Authentication
gem 'bcrypt', '~> 3.1.7'
gem 'omniauth-google-oauth2'
gem 'omniauth-rails_csrf_protection'

# External APIs
gem 'geocoder'
gem 'ruby-openai'

# File Upload
gem 'aws-sdk-s3', require: false

# Pagination
gem 'kaminari'

group :development, :test do
  gem 'rspec-rails'
  gem 'factory_bot_rails'
  gem 'faker'
end

group :development do
  gem 'rubocop', require: false
  gem 'bullet'
end

group :test do
  gem 'capybara'
  gem 'selenium-webdriver'
  gem 'simplecov', require: false
end
```

### バージョン固定

**Gemfile.lock**:
- すべての依存関係のバージョンを固定
- `bundle install` で生成
- Gitで管理

**更新手順**:
```bash
# 全Gem更新
bundle update

# 特定Gem更新
bundle update rails

# セキュリティアップデート確認
bundle audit
```

## デプロイ戦略

### Fly.io デプロイ

**初回デプロイ**:
```bash
# Fly.io CLIインストール
brew install flyctl

# ログイン
fly auth login

# アプリ作成
fly launch

# PostgreSQL作成
fly postgres create

# PostgreSQL接続
fly postgres attach <postgres-app-name>

# Secrets設定
fly secrets set RAILS_MASTER_KEY=<master-key>

# デプロイ
fly deploy
```

**継続的デプロイ（GitHub Actions）**:
```yaml
# .github/workflows/deploy.yml
name: Deploy

on:
  push:
    branches: [main]

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: superfly/flyctl-actions/setup-flyctl@master
      - run: flyctl deploy --remote-only
        env:
          FLY_API_TOKEN: ${{ secrets.FLY_API_TOKEN }}
```

**デプロイフロー**:
1. mainブランチにマージ
2. GitHub ActionsがCI実行（RSpec + RuboCop）
3. CIパス後、自動的にFly.ioへデプロイ
4. Fly.ioでDockerイメージビルド
5. PostgreSQLマイグレーション実行
6. 新インスタンス起動
7. ヘルスチェック通過後、旧インスタンス停止

### データベースマイグレーション

**本番環境でのマイグレーション**:
```bash
# Fly.io SSH接続
fly ssh console

# マイグレーション実行
rails db:migrate
```

**ゼロダウンタイムマイグレーション**:
- カラム追加: 問題なし
- カラム削除: 段階的に実施（まず使用停止、次回デプロイで削除）
- テーブル追加: 問題なし

### ロールバック

**アプリケーションロールバック**:
```bash
# 前バージョンに戻す
fly releases
fly releases rollback <version>
```

**データベースロールバック**:
```bash
# マイグレーションを1つ戻す
fly ssh console
rails db:rollback
```

## モニタリング・ロギング

### ロギング戦略

**Rails Logger**:
```ruby
# config/environments/production.rb
config.log_level = :info
config.log_tags = [:request_id]
```

**ログ確認**:
```bash
# Fly.ioログ確認
fly logs
```

### エラートラッキング（将来的）

**Sentry統合**:
- エラー自動送信
- スタックトレース記録
- アラート通知

### パフォーマンスモニタリング（将来的）

**New Relic / Scout APM**:
- レスポンスタイム測定
- データベースクエリ分析
- N+1問題検出

## まとめ

このドキュメントでは、ちゃくどんプロジェクトの技術アーキテクチャを詳細に定義しました。

**主要ポイント**:
- **Rails 7.0 + PostgreSQL 14**: モダンで安定したスタック
- **MVC + Service Object**: 明確な責務分離
- **GoodJob**: PostgreSQLベースのシンプルなバックグラウンドジョブ
- **Fly.io**: 簡単なデプロイとスケーリング
- **セキュリティ**: bcrypt、CSRF、SQL Injection、XSS対策
- **テスト**: RSpec 80%カバレッジ目標、CI/CD統合

次のステップ:
- `development-guidelines.md`でコーディング規約を明確化
- `repository-structure.md`でファイル配置ルールを定義
- 実装時はこのドキュメントを参照
