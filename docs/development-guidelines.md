# 開発ガイドライン (Development Guidelines)

## スキル参照

このガイドラインは、ちゃくどんプロジェクト固有の規約です。
汎用的なコーディング原則・パターンは以下を参照してください：
- [実装ガイド (汎用)](./.claude/skills/development-guidelines/guides/implementation.md) - Ruby/Rails基本規約、エラーハンドリング、セキュリティ原則
- [プロセスガイド (汎用)](./.claude/skills/development-guidelines/guides/process.md) - Git Flow理論、テスト戦略、CI/CDパターン

---

## コーディング規約

### 命名規則

#### Ruby/Railsの基本ルール

**変数・メソッド**: snake_case
```ruby
# ✅ 良い例
user_name = "田中"
def calculate_wait_time
  (ended_at - started_at) / 60.0
end

# ❌ 悪い例
userName = "田中"
def calculateWaitTime
end
```

**定数**: SCREAMING_SNAKE_CASE
```ruby
# ✅ 良い例
MAX_WAIT_TIME = 180  # 分
DEFAULT_RECORD_LIMIT = 20

# ❌ 悪い例
maxWaitTime = 180
DefaultRecordLimit = 20
```

**クラス・モジュール**: PascalCase
```ruby
# ✅ 良い例
class RamenShop
end

class DocumentFetcher
end

module ShopInfo
end

# ❌ 悪い例
class ramen_shop
end

class document_fetcher
end
```

#### モデル

**モデル名**: 単数形、PascalCase
```ruby
# ✅ 良い例
class User < ApplicationRecord
end

class Record < ApplicationRecord
end

class RamenShop < ApplicationRecord
end

# ❌ 悪い例
class Users < ApplicationRecord
end

class ramen_shop < ApplicationRecord
end
```

**テーブル名**: 複数形、snake_case（Railsが自動変換）
```ruby
# Userモデル → usersテーブル
# Record → records
# RamenShop → ramen_shops
```

#### コントローラー

**コントローラー名**: 複数形 + Controller
```ruby
# ✅ 良い例
class RecordsController < ApplicationController
end

class RamenShopsController < ApplicationController
end

class LineStatusesController < ApplicationController
end

# ❌ 悪い例
class RecordController < ApplicationController
end

class RamenShopController < ApplicationController
end
```

#### サービス（非推奨）
⚠️ **非推奨**: Service Objectは使用しません。
**現状**: 6つのファイルが存在し、`lib/tasks/scraping.thor` で使用されています（スクレイピングタスク用）。
**方針**: スクレイピングワークフロー専用として維持。新規ビジネスロジックは `app/models/` に配置

**代替案**:
```ruby
# ✅ 良い例（app/models/にPOROとして実装）
# app/models/document_fetcher.rb
class DocumentFetcher  # PORO: 外部HTTPクライアント
end

# app/models/concerns/retirable.rb
module Retirable  # Concern: 終了処理の振る舞い
end
```

#### Concerns

**現状**: `app/models/concerns/` ディレクトリは現在空です（.keepファイルのみ）

**将来的な実装**:

**Concern名**: 形容詞形（-able）または機能名

```ruby
# ✅ 良い例（将来的な実装）
module Retirable  # 終了処理の振る舞い
end

module Geocodable  # 位置情報取得の振る舞い
end

module Likeable  # いいね機能の振る舞い
end

# ❌ 悪い例
module RecordHelper  # 抽象的すぎる
end

module Utils  # 目的が不明
end
```

#### ジョブ

**ジョブ名**: 目的 + Job
```ruby
# ✅ 良い例
class AutoRetireRecordJob < ApplicationJob
end

class SpeakCheerMessageJob < ApplicationJob
end

# ❌ 悪い例
class RecordJob < ApplicationJob
end

class CheerJob < ApplicationJob
end
```

#### Boolean属性

**Boolean属性**: `is_`, `has_`, `can_`, `should_` プレフィックス
```ruby
# ✅ 良い例（スキーマ定義）
t.boolean :is_retired, default: false
t.boolean :auto_retired, default: false
t.boolean :is_test, default: false
t.boolean :activated, default: false
t.boolean :admin, default: false

# メソッド
def retired?
  is_retired
end

def test_mode?
  is_test_mode
end
```

#### ファイル名

**モデル**: 単数形、snake_case
```
app/models/user.rb
app/models/record.rb
app/models/ramen_shop.rb
app/models/line_status.rb
```

**コントローラー**: 複数形、snake_case + _controller
```
app/controllers/records_controller.rb
app/controllers/ramen_shops_controller.rb
app/controllers/line_statuses_controller.rb
```

**ジョブ**: snake_case + _job
```
app/jobs/auto_retire_record_job.rb
app/jobs/speak_cheer_message_job.rb
```

### コードフォーマット

#### RuboCop設定（`.rubocop.yml`に基づく）

**インデント**: 2スペース

**行の長さ**: デフォルト（120文字推奨）

**ハッシュ記法**: Ruby 1.9+スタイル
```ruby
# ✅ 良い例
user = { name: '田中', email: 'tanaka@example.com' }

# ❌ 悪い例
user = { :name => '田中', :email => 'tanaka@example.com' }
```

**Lambda記法**: `->` を使用
```ruby
# ✅ 良い例
process = ->(x) { x * 2 }

# ❌ 悪い例
process = lambda { |x| x * 2 }
```

**ブロック**: `braces_for_chaining`（メソッドチェーン時は`{}`）
```ruby
# ✅ 良い例（メソッドチェーン）
users.select { |u| u.active? }.map { |u| u.name }

# ✅ 良い例（do...end）
users.each do |user|
  puts user.name
  puts user.email
end

# ❌ 悪い例（複数行で{}）
users.each { |user|
  puts user.name
  puts user.email
}
```

**文字列**: シングルクォート優先（補間がない場合）
```ruby
# ✅ 良い例
name = 'ちゃくどん'
message = "こんにちは、#{name}さん"

# ❌ 悪い例
name = "ちゃくどん"  # 補間がないのにダブルクォート
```

### コメント規約

#### クラス・モジュールのドキュメント

```ruby
# Webページからラーメン店舗情報を取得するサービス
#
# @example
#   fetcher = DocumentFetcher.new
#   html = fetcher.fetch('https://example.com')
class DocumentFetcher
  # 指定されたURLからHTMLを取得する
  #
  # @param url [String] 取得するURL
  # @return [String, nil] HTML文字列、失敗時はnil
  def fetch(url)
    # ...
  end
end
```

#### メソッドのドキュメント

**シンプルなメソッド**: コメント不要（メソッド名が自己説明的）
```ruby
# ✅ 良い例（コメント不要）
def calculate_wait_time
  (ended_at - started_at) / 60.0
end

# ❌ 悪い例（冗長なコメント）
# 待ち時間を計算する
def calculate_wait_time
  (ended_at - started_at) / 60.0
end
```

**複雑なメソッド**: RDocスタイル
```ruby
# 1日経過した計測中のレコードを自動終了する
#
# @return [Integer] 自動終了したレコード数
def auto_retire_old_records
  records = Record.where('started_at < ? AND ended_at IS NULL', 1.day.ago)
  count = 0

  records.find_each do |record|
    record.update(auto_retired: true, ended_at: record.started_at + 1.day)
    count += 1
  end

  count
end
```

#### インラインコメント

**必要な場合のみ**:
```ruby
# ✅ 良い例（複雑なロジックの説明）
def geocode
  # Geocoder gemが住所から自動的に緯度経度を取得
  # 失敗した場合はバリデーションエラーになる
  super
end

# ❌ 悪い例（自明なコメント）
# ユーザーIDを取得
user_id = current_user.id
```

### RSpec規約

**スタイル**: `to_not` を使用（`not_to` ではない）
```ruby
# ✅ 良い例
expect(user.email).to_not be_nil

# ❌ 悪い例
expect(user.email).not_to be_nil
```

**Context命名**: when, with, without, if, unless, for, before, after, during
```ruby
# ✅ 良い例
RSpec.describe Record, type: :model do
  describe '#calculate_wait_time' do
    context 'when both started_at and ended_at are present' do
      it '待ち時間を正しく計算する'
    end

    context 'when ended_at is nil' do
      it '待ち時間を計算しない'
    end
  end
end
```

> **エラーハンドリングと関数設計**: 汎用的なエラーハンドリングパターン、関数設計の原則については [実装ガイド - エラーハンドリング](./.claude/skills/development-guidelines/guides/implementation.md#エラーハンドリング) を参照してください。

## Gitワークフロー

> **Git Flow理論とベストプラクティス**: ブランチ戦略の理論、Conventional Commits の詳細、一般的なCI/CDパターンについては [プロセスガイド - Git運用ルール](./.claude/skills/development-guidelines/guides/process.md#git運用ルール) を参照してください。

### ちゃくどん固有のブランチ戦略

**メインブランチ**: `main`
- 常にデプロイ可能な状態
- 直接コミット禁止

**フィーチャーブランチ**: `feature/<機能名>` または `fix/<バグ名>`
```bash
# 良い例
git checkout -b feature/add-review-function
git checkout -b fix/geocoder-timeout

# 悪い例
git checkout -b my-work
git checkout -b test
```

### コミットメッセージ規約

**フォーマット**:
```
<type>: <subject>

<body>

<footer>
```

**Type**:
- `feat`: 新機能
- `fix`: バグ修正
- `refactor`: リファクタリング
- `test`: テスト追加・修正
- `docs`: ドキュメント変更
- `style`: コードフォーマット変更
- `chore`: ビルド・補助ツール変更

**例**:
```
feat: Add review and rating feature to RamenShop

- Add Review model with rating and comment fields
- Add ReviewsController with CRUD actions
- Add review form to shop detail page

Closes #123
```

```
fix: Fix Geocoder timeout issue

- Increase timeout to 10 seconds
- Add retry logic for failed geocoding requests

Fixes #456
```

### プルリクエストプロセス

#### 1. PR作成前

```bash
# 最新のmainを取得
git checkout main
git pull origin main

# フィーチャーブランチにマージ
git checkout feature/add-review-function
git merge main

# テスト実行
docker compose exec app bundle exec rspec

# Lint実行
docker compose exec app bundle exec rubocop

# コミット
git add .
git commit -m "feat: Add review function"

# Push
git push origin feature/add-review-function
```

#### 2. PR作成

**タイトル**: `[feat] レビュー機能の追加` または `feat: Add review function`

**説明テンプレート**:
```markdown
## 概要
レビュー機能を追加しました。ユーザーが店舗に対して5段階評価とコメントを投稿できます。

## 変更内容
- [ ] Reviewモデル追加（rating, comment）
- [ ] ReviewsController追加（CRUD）
- [ ] 店舗詳細ページにレビューフォーム追加
- [ ] レビュー一覧表示機能

## テスト
- [ ] RSpecテスト追加（モデル、コントローラー）
- [ ] 手動テストでフォーム動作確認

## スクリーンショット
（必要に応じて）

## 関連Issue
Closes #123
```

#### 3. コードレビュー

**レビュアーの確認事項**:
- [ ] テストがパスしているか
- [ ] RuboCopエラーがないか
- [ ] コードが読みやすいか
- [ ] ドキュメント（READMEなど）の更新が必要か
- [ ] セキュリティ上の問題がないか
- [ ] パフォーマンス上の問題がないか

**レビューコメント例**:
```markdown
# 良い指摘
このクエリはN+1問題を引き起こす可能性があります。
`includes(:user, :ramen_shop)` を追加することをお勧めします。

# 悪い指摘
このコードは良くないです。（具体的な理由がない）
```

#### 4. マージ

- すべてのテストがパス
- 少なくとも1人の承認が必要
- コメントがすべて解決済み
- Squash and Merge（コミット履歴を整理）

## テスト戦略

> **テストパターン**: モデルテスト、リクエストテスト、システムテストのパターンと RSpec/FactoryBot のベストプラクティスは [実装ガイド - RSpec テスト](./.claude/skills/development-guidelines/guides/implementation.md#rspec-テスト) を参照してください。

### プロジェクト固有の要件

**テストカバレッジ

**目標**: 80%以上

**測定**:
```ruby
# spec/spec_helper.rb
require 'simplecov'
SimpleCov.start 'rails' do
  add_filter '/spec/'
  add_filter '/config/'
  add_filter '/vendor/'
end
```

**確認**:
```bash
docker compose exec app bundle exec rspec
open coverage/index.html
```

## コードレビュー基準

### チェックリスト

#### 機能性
- [ ] 要件を満たしているか
- [ ] エッジケースが考慮されているか
- [ ] エラーハンドリングが適切か

#### コード品質
- [ ] Rails規約に従っているか
- [ ] RuboCopエラーがないか
- [ ] コードが読みやすいか
- [ ] 適切に関心が分離されているか（MVC, Concerns）
- [ ] すべてのロジックが `app/models/` に配置されているか
- [ ] `app/services/` を使用していないか（非推奨）
- [ ] `app/models/` の3分類が適切か（ActiveRecord、Concerns、PORO）
- [ ] モデルが肥大化していないか（Concernsへの分割を検討）
- [ ] Concernsの命名が適切か（-able形式または機能名）

#### テスト
- [ ] テストがあるか
- [ ] テストが適切か（単体テスト、統合テスト）
- [ ] カバレッジが低下していないか

#### パフォーマンス
- [ ] N+1問題がないか
- [ ] 不要なクエリがないか
- [ ] インデックスが適切か

#### セキュリティ
- [ ] SQL Injection のリスクがないか
- [ ] XSS のリスクがないか
- [ ] 認証・認可が適切か
- [ ] 秘密情報がハードコードされていないか

## まとめ

このガイドラインは、ちゃくどんプロジェクトのコード品質を保ち、チーム開発を円滑にするためのものです。

**重要なポイント**:
- Rails規約に従う（snake_case, PascalCase）
- RuboCop設定を遵守
- テストを書く（80%カバレッジ目標）
- コードレビューを丁寧に行う
- Gitワークフローを守る

**参考資料**:
- [Ruby Style Guide](https://rubystyle.guide/)
- [Rails Guide](https://guides.rubyonrails.org/)
- [RSpec Best Practices](https://www.betterspecs.org/)
