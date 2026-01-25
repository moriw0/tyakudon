# 実装ガイド (Implementation Guide)

## プロジェクト固有の規約

このドキュメントは汎用的な実装原則を記載しています。
ちゃくどんプロジェクトでの具体的な適用方法は以下を参照してください：
- [開発ガイドライン (ちゃくどん)](../../../docs/development-guidelines.md) - プロジェクト固有のコーディング規約、Dockerコマンド、Git workflow

---

## Ruby/Rails 基本規約

### クラスとモジュール

**命名規則**:
```ruby
# ✅ 良い例: PascalCase
class TaskManager
end

class UserAuthenticationService
end

# モジュール: PascalCase
module Geocodable
  extend ActiveSupport::Concern
end

# ❌ 悪い例: 小文字やスネークケース
class task_manager
end

class TASKMANAGER
end
```

**継承とインクルード**:
```ruby
# ✅ 良い例: 適切な継承
class Record < ApplicationRecord
  include RecordsHelper

  # ...
end

# Concern の使用
module Authenticatable
  extend ActiveSupport::Concern

  included do
    before_action :require_login
  end

  def current_user
    @current_user ||= User.find_by(id: session[:user_id])
  end
end
```

### 定数

**命名規則**:
```ruby
# ✅ 良い例: UPPER_SNAKE_CASE
MAX_RETRY_COUNT = 3
API_BASE_URL = 'https://api.example.com'
DEFAULT_TIMEOUT = 5

# 正規表現定数
VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d-]+(\.[a-z\d-]+)*\.[a-z]+\z/i

# ハッシュ定数（freeze で不変にする）
CONFIG = {
  max_retry_count: 3,
  api_base_url: 'https://api.example.com'
}.freeze

# ❌ 悪い例: camelCase
maxRetryCount = 3
```

### 変数とメソッド

**命名規則**:
```ruby
# ✅ 良い例: snake_case
user_name = 'John'
task_list = []
is_completed = true

# メソッド: snake_case、動詞で始める
def fetch_user_data
  # ...
end

def validate_email(email)
  # ...
end

def calculate_total_price(items)
  # ...
end

# Boolean メソッド: ? で終わる
def completed?
  ended_at.present?
end

def activated?
  activated
end

# 破壊的メソッド: ! で終わる
def downcase_email!
  email.downcase!
end

# ❌ 悪い例: camelCase
userName = 'John'
def fetchUserData
end
```

**ローカル変数 vs インスタンス変数**:
```ruby
# ✅ 良い例: 適切な使い分け
class RecordsController < ApplicationController
  def show
    # インスタンス変数: ビューで使用
    @record = Record.find(params[:id])
    @tweet_url = generate_tweet_url(@record, request.url)

    # ローカル変数: コントローラー内のみで使用
    user = @record.user
  end

  private

  # プライベートメソッドでインスタンス変数を設定
  def set_record
    @record = Record.find(params[:id])
  end
end
```

### ファイル名とディレクトリ構造

```ruby
# ファイル名: snake_case
# app/models/user.rb
# app/models/ramen_shop.rb
# app/models/document_fetcher.rb  # PORO（外部クライアント）
# app/controllers/records_controller.rb

# ディレクトリ構造
# app/
#   models/            # すべてのロジック（ActiveRecord、Concerns、PORO）
#     concerns/        # 共有する振る舞い
#   controllers/
#   jobs/              # バックグラウンドジョブ
#   helpers/           # ビューヘルパー
#   mailers/           # メイラー
```

## ActiveRecord モデル

### Associations (関連付け)

**基本的な関連付け**:
```ruby
# ✅ 良い例: 適切な関連付けと dependent オプション
class User < ApplicationRecord
  # has_many: 1対多
  has_many :records, dependent: :restrict_with_exception
  has_many :favorites, dependent: :destroy
  has_many :shop_register_requests, dependent: :destroy

  # through: 多対多
  has_many :favorite_shops, through: :favorites, source: :ramen_shop
  has_many :like_records, through: :likes, source: :record

  # has_one_attached: Active Storage
  has_one_attached :avatar
end

class Record < ApplicationRecord
  # belongs_to: 多対1
  belongs_to :user
  belongs_to :ramen_shop

  # has_many: 1対多
  has_many :line_statuses, dependent: :destroy
  has_many :cheer_messages, dependent: :destroy

  # has_one_attached
  has_one_attached :image
end

class RamenShop < ApplicationRecord
  has_many :records, dependent: :restrict_with_exception
  has_many :favorites, dependent: :destroy
end
```

**dependent オプションの使い分け**:
```ruby
# :destroy - 関連レコードも削除（コールバック実行）
has_many :favorites, dependent: :destroy

# :delete_all - 関連レコードを削除（コールバック実行なし、高速）
has_many :notifications, dependent: :delete_all

# :restrict_with_exception - 関連レコードがある場合削除を防ぐ
has_many :records, dependent: :restrict_with_exception

# :nullify - 外部キーを NULL に設定
has_many :comments, dependent: :nullify
```

### Validations (バリデーション)

**基本的なバリデーション**:
```ruby
# ✅ 良い例: 明確なバリデーション
class User < ApplicationRecord
  # 存在チェック
  validates :name, presence: true, length: { maximum: 50 }

  # 形式チェック
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d-]+(\.[a-z\d-]+)*\.[a-z]+\z/i
  validates :email,
            presence: true,
            length: { maximum: 255 },
            format: { with: VALID_EMAIL_REGEX },
            uniqueness: true

  # パスワード（条件付き）
  validates :password,
            presence: true,
            length: { minimum: 6 },
            allow_nil: true,
            unless: :uid?

  # Active Storage
  validates :avatar,
            content_type: { in: %i[png jpg jpeg],
                           message: :file_type_invalid },
            size: { less_than_or_equal_to: 9.megabytes,
                   message: :file_size_exceed }
end
```

**カスタムバリデーション**:
```ruby
# ✅ 良い例: カスタムバリデーションメソッド
class Task < ApplicationRecord
  validate :deadline_cannot_be_in_the_past
  validate :title_must_not_contain_spam_words

  private

  def deadline_cannot_be_in_the_past
    return if deadline.blank? || deadline >= Date.today

    errors.add(:deadline, '締切は今日以降の日付を設定してください')
  end

  def title_must_not_contain_spam_words
    spam_words = %w[スパム 広告 宣伝]
    return unless spam_words.any? { |word| title.include?(word) }

    errors.add(:title, '不適切な単語が含まれています')
  end
end

# カスタムバリデータクラス
class EmailValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    unless value =~ /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i
      record.errors.add(attribute, options[:message] || 'は有効なメールアドレスではありません')
    end
  end
end

class User < ApplicationRecord
  validates :email, email: true
end
```

### Callbacks (コールバック)

**タイミングと使い方**:
```ruby
# ✅ 良い例: 適切なコールバック使用
class User < ApplicationRecord
  # 保存前: データの正規化
  before_save :downcase_email

  # 作成前: 初期値設定
  before_create :create_activation_digest

  # 作成後: 外部サービス通知（トランザクション後）
  after_commit :send_welcome_email, on: :create

  # 更新後
  after_update :notify_profile_change, if: :saved_change_to_name?

  private

  def downcase_email
    email.downcase!
  end

  def create_activation_digest
    self.activation_token = User.new_token
    self.activation_digest = User.digest(activation_token)
  end

  def send_welcome_email
    UserMailer.welcome_email(self).deliver_later
  end

  def notify_profile_change
    # プロフィール変更通知
  end
end

# ❌ 悪い例: コールバックに複雑なロジック
class User < ApplicationRecord
  after_create :do_many_things

  private

  def do_many_things
    # 複数の処理を詰め込まない
    create_profile
    send_email
    create_notification
    update_statistics
    # => Service オブジェクトに抽出すべき
  end
end
```

### スコープとクエリメソッド

```ruby
# ✅ 良い例: スコープの定義
class Record < ApplicationRecord
  # スコープ: 再利用可能なクエリ
  scope :active, -> { where(ended_at: nil) }
  scope :completed, -> { where.not(ended_at: nil) }
  scope :recent, -> { order(created_at: :desc) }
  scope :by_shop, ->(shop_id) { where(ramen_shop_id: shop_id) }

  # クラスメソッド: 複雑なクエリ
  def self.popular_this_week
    where('created_at >= ?', 1.week.ago)
      .group(:ramen_shop_id)
      .order('count_id DESC')
      .limit(10)
      .count(:id)
  end
end

# 使用例
recent_records = Record.active.recent.limit(20)
shop_records = Record.by_shop(shop.id).completed
```

## コントローラー設計

### RESTful アクション

```ruby
# ✅ 良い例: RESTful コントローラー
class RecordsController < ApplicationController
  before_action :logged_in_user, except: %i[show index]
  before_action :set_record, only: %i[show edit update destroy]
  before_action :correct_user, only: %i[edit update destroy]

  # GET /records
  def index
    @records = Record.recent.page(params[:page])
  end

  # GET /records/:id
  def show
    @tweet_url = generate_tweet_url(@record, request.url)
  end

  # GET /records/new
  def new
    @ramen_shop = RamenShop.find(params[:ramen_shop_id])
    @record = current_user.records.build(ramen_shop: @ramen_shop)
  end

  # GET /records/:id/edit
  def edit
  end

  # POST /records
  def create
    @record = current_user.records.build(record_params)

    if @record.save
      redirect_to @record, notice: '記録を作成しました', status: :see_other
    else
      render :new, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /records/:id
  def update
    if @record.update(record_params)
      redirect_to @record, notice: '更新しました', status: :see_other
    else
      render :edit, status: :unprocessable_entity
    end
  end

  # DELETE /records/:id
  def destroy
    @record.destroy
    redirect_to records_url, notice: '削除しました', status: :see_other
  end

  private

  def set_record
    @record = Record.find(params[:id])
  end

  def correct_user
    return if current_user?(@record.user)

    redirect_to root_path, alert: '不正なアクセスです', status: :see_other
  end

  def record_params
    params.require(:record).permit(:started_at, :ended_at, :comment, :image)
  end
end
```

### Before Actions

```ruby
# ✅ 良い例: before_action の活用
class RecordsController < ApplicationController
  # 認証チェック（show 以外）
  before_action :logged_in_user, except: %i[show]

  # レコード取得（特定アクションのみ）
  before_action :set_record, only: %i[show edit update destroy]

  # 権限チェック
  before_action :correct_user, only: %i[edit update destroy]

  # カスタムチェック
  before_action :check_auto_retired, only: %i[measure calculate]

  private

  def logged_in_user
    return if logged_in?

    flash[:alert] = 'ログインしてください'
    redirect_to login_url, status: :see_other
  end

  def set_record
    @record = Record.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    redirect_to root_path, alert: 'レコードが見つかりません', status: :see_other
  end

  def correct_user
    return if current_user?(@record.user)

    redirect_to root_path, alert: '不正なアクセスです', status: :see_other
  end
end
```

### Strong Parameters

```ruby
# ✅ 良い例: Strong Parameters
class RecordsController < ApplicationController
  def create
    @record = Record.new(create_record_params)
    # ...
  end

  def update
    @record.update(update_record_params)
    # ...
  end

  private

  # 作成時: 必要な属性のみ
  def create_record_params
    params.require(:record).permit(
      :ramen_shop_id,
      :user_id,
      :started_at,
      line_statuses_attributes: %i[line_number line_type comment image]
    )
  end

  # 更新時: 編集可能な属性のみ
  def update_record_params
    params.require(:record).permit(:comment, :image)
  end

  # 計算時: 特定の属性のみ
  def calculated_record_params
    params.require(:record).permit(:ended_at, :wait_time)
  end
end

# ❌ 悪い例: すべての属性を許可
def record_params
  params.require(:record).permit!  # 危険！
end
```

### Flash メッセージとリダイレクト

```ruby
# ✅ 良い例: 適切な Flash とリダイレクト
def create
  if @record.save
    # 成功: notice と :see_other ステータス
    redirect_to @record, notice: '作成しました', status: :see_other
  else
    # 失敗: render と :unprocessable_entity ステータス
    render :new, status: :unprocessable_entity
  end
end

def destroy
  @record.destroy
  redirect_to records_url, notice: '削除しました', status: :see_other
end

def update
  if @record.update(record_params)
    redirect_to @record, notice: '更新しました', status: :see_other
  else
    # エラー表示のため render
    render :edit, status: :unprocessable_entity
  end
end

# flash.now: リダイレクトなしで表示
def measure
  flash.now[:notice] = '接続しました'
  render :measure
end
```

## Service オブジェクト（非推奨）

⚠️ **非推奨**: Service Object パターンは使用しません。
今後はすべてのロジックを `app/models/` に配置してください。

**方針**: Railsの思想 "Fat Model, Skinny Controller" に従います。

**app/models/ の3分類**:
1. **ActiveRecord**: DBテーブルに紐づくモデル (user.rb, record.rb等)
2. **Concerns**: 共有する振る舞い (concerns/retirable.rb等)
3. **PORO**: 単独のロジック (document_fetcher.rb等の外部クライアント)

**代替実装例**:
```ruby
# app/models/document_fetcher.rb (PORO)
class DocumentFetcher
  class FetchError < StandardError; end

  def self.fetch_document_from_url(url)
    html_content = URI.parse(url).read
    Nokogiri::HTML(html_content)
  rescue OpenURI::HTTPError => e
    Rails.logger.error("Document fetch failed: #{e.message}")
    raise FetchError, "ドキュメントの取得に失敗しました: #{url}"
  end
end

# app/models/concerns/retirable.rb (Concern)
module Retirable
  extend ActiveSupport::Concern

  def retire!
    update(is_retired: true, ended_at: Time.current)
  end
end
```

詳細は [docs/development-guidelines.md](../../../docs/development-guidelines.md) を参照してください。

## エラーハンドリング

### カスタムエラークラス

```ruby
# ✅ 良い例: 階層的なエラークラス
class ApplicationError < StandardError; end

class ValidationError < ApplicationError
  attr_reader :field, :value

  def initialize(message, field: nil, value: nil)
    super(message)
    @field = field
    @value = value
  end
end

class NotFoundError < ApplicationError
  attr_reader :resource, :id

  def initialize(resource, id)
    super("#{resource} not found: #{id}")
    @resource = resource
    @id = id
  end
end

class AuthorizationError < ApplicationError; end
class DatabaseError < ApplicationError; end
```

### エラーハンドリングパターン

```ruby
# ✅ 良い例: 適切な rescue
class TaskService
  def create_task(params)
    validate_params!(params)

    task = Task.create!(params)
    notify_assignee(task)
    task
  rescue ActiveRecord::RecordInvalid => e
    Rails.logger.warn("Task creation failed: #{e.message}")
    raise ValidationError.new("タスクの作成に失敗しました: #{e.message}")
  rescue StandardError => e
    Rails.logger.error("Unexpected error: #{e.message}")
    raise DatabaseError, "タスクの作成中に予期しないエラーが発生しました"
  end

  def find_task(id)
    Task.find(id)
  rescue ActiveRecord::RecordNotFound
    raise NotFoundError.new('Task', id)
  end

  private

  def validate_params!(params)
    raise ValidationError.new('タイトルは必須です', field: :title) if params[:title].blank?
    raise ValidationError.new('担当者は必須です', field: :assignee) if params[:assignee_id].blank?
  end

  def notify_assignee(task)
    TaskMailer.assigned(task).deliver_later
  rescue StandardError => e
    # メール送信失敗はログのみ（タスク作成は成功）
    Rails.logger.error("Failed to send notification: #{e.message}")
  end
end
```

### コントローラーでのエラーハンドリング

```ruby
# ✅ 良い例: ApplicationController でエラーをキャッチ
class ApplicationController < ActionController::Base
  rescue_from ActiveRecord::RecordNotFound, with: :render_404
  rescue_from NotFoundError, with: :render_404
  rescue_from AuthorizationError, with: :render_403
  rescue_from ValidationError, with: :render_422

  private

  def render_404(exception = nil)
    logger.info("404 Error: #{exception&.message}")
    render file: Rails.root.join('public/404.html'), status: :not_found, layout: false
  end

  def render_403(exception = nil)
    logger.warn("403 Error: #{exception&.message}")
    render file: Rails.root.join('public/403.html'), status: :forbidden, layout: false
  end

  def render_422(exception)
    logger.warn("422 Error: #{exception.message}")
    flash[:alert] = exception.message
    redirect_back fallback_location: root_path, status: :see_other
  end
end
```

## RSpec テスト

### Model Spec

```ruby
# ✅ 良い例: Model のテスト
RSpec.describe User do
  # let: 遅延評価（使用時に初期化）
  let(:user) { build(:user) }
  let(:ramen_shop) { create(:ramen_shop) }

  # describe: メソッドやクラスの説明
  describe 'validations' do
    # it: テストケース
    it 'is valid with name and email' do
      expect(user).to be_valid
    end

    it 'is invalid without a name' do
      user.name = '    '
      user.valid?
      expect(user.errors[:name]).to include('ニックネームを入力してください。')
    end

    it 'is invalid with a too long name' do
      user.name = 'a' * 51
      user.valid?
      expect(user.errors[:name]).to include('ニックネームは50文字以内で入力してください。')
    end

    it 'is invalid with duplicate email' do
      create(:user, email: 'test@example.com')
      duplicate_user = build(:user, email: 'test@example.com')
      duplicate_user.valid?
      expect(duplicate_user.errors[:email]).to include('メールアドレスがすでに使用されています。')
    end
  end

  describe 'associations' do
    # shoulda-matchers の使用
    it { is_expected.to have_many(:records).dependent(:restrict_with_exception) }
    it { is_expected.to have_many(:favorites).dependent(:destroy) }
    it { is_expected.to have_one_attached(:avatar) }
  end

  # context: 条件による分岐
  describe '#favorites?' do
    context 'when shop is favorited' do
      before { user.add_favorite(ramen_shop) }

      it 'returns true' do
        expect(user).to be_favorites(ramen_shop)
      end
    end

    context 'when shop is not favorited' do
      it 'returns false' do
        expect(user).to_not be_favorites(ramen_shop)
      end
    end
  end

  describe '#add_favorite' do
    it 'adds shop to favorites' do
      expect {
        user.add_favorite(ramen_shop)
      }.to change { user.favorite_shops.count }.by(1)
    end

    it 'does not add duplicate favorite' do
      user.add_favorite(ramen_shop)
      expect {
        user.add_favorite(ramen_shop)
      }.to_not change { user.favorite_shops.count }
    end
  end
end
```

### Request Spec

```ruby
# ✅ 良い例: Request Spec
RSpec.describe 'Records', type: :request do
  let(:user) { create(:user) }
  let(:shop) { create(:ramen_shop) }
  let(:record) { create(:record, user: user, ramen_shop: shop) }

  describe 'GET /records/:id' do
    it 'returns success response' do
      get record_path(record)
      expect(response).to have_http_status(:success)
    end

    it 'renders show template' do
      get record_path(record)
      expect(response).to render_template(:show)
    end
  end

  describe 'POST /records' do
    context 'when logged in' do
      before { sign_in(user) }

      context 'with valid parameters' do
        let(:valid_params) do
          {
            record: {
              ramen_shop_id: shop.id,
              started_at: Time.current
            }
          }
        end

        it 'creates a new record' do
          expect {
            post records_path, params: valid_params
          }.to change(Record, :count).by(1)
        end

        it 'redirects to measure page' do
          post records_path, params: valid_params
          expect(response).to redirect_to(measure_record_path(Record.last))
        end

        it 'sets flash notice' do
          post records_path, params: valid_params
          follow_redirect!
          expect(flash[:notice]).to be_present
        end
      end

      context 'with invalid parameters' do
        let(:invalid_params) do
          { record: { ramen_shop_id: nil } }
        end

        it 'does not create a record' do
          expect {
            post records_path, params: invalid_params
          }.to_not change(Record, :count)
        end

        it 'renders new template' do
          post records_path, params: invalid_params
          expect(response).to render_template(:new)
        end

        it 'returns unprocessable entity status' do
          post records_path, params: invalid_params
          expect(response).to have_http_status(:unprocessable_entity)
        end
      end
    end

    context 'when not logged in' do
      it 'redirects to login page' do
        post records_path, params: { record: { ramen_shop_id: shop.id } }
        expect(response).to redirect_to(login_path)
      end
    end
  end

  describe 'DELETE /records/:id' do
    let!(:record) { create(:record, user: user) }

    before { sign_in(user) }

    it 'deletes the record' do
      expect {
        delete record_path(record)
      }.to change(Record, :count).by(-1)
    end

    it 'redirects to records index' do
      delete record_path(record)
      expect(response).to redirect_to(records_path)
    end
  end
end
```

### Service Spec

```ruby
# ✅ 良い例: Service のテスト
RSpec.describe DocumentFetcher do
  describe '.fetch_document_from_url' do
    let(:url) { 'https://example.com' }

    context 'when fetch succeeds' do
      before do
        stub_request(:get, url).to_return(
          status: 200,
          body: '<html><body>Test</body></html>'
        )
      end

      it 'returns Nokogiri document' do
        doc = described_class.fetch_document_from_url(url)
        expect(doc).to be_a(Nokogiri::HTML::Document)
      end

      it 'parses HTML content' do
        doc = described_class.fetch_document_from_url(url)
        expect(doc.text).to include('Test')
      end
    end

    context 'when fetch fails' do
      before do
        stub_request(:get, url).to return(status: 404)
      end

      it 'raises FetchError' do
        expect {
          described_class.fetch_document_from_url(url)
        }.to raise_error(DocumentFetcher::FetchError)
      end

      it 'logs error message' do
        allow(Rails.logger).to receive(:error)

        begin
          described_class.fetch_document_from_url(url)
        rescue DocumentFetcher::FetchError
          # Expected
        end

        expect(Rails.logger).to have_received(:error).with(/Document fetch failed/)
      end
    end
  end
end
```

### FactoryBot の使用

```ruby
# ✅ 良い例: Factory の定義
# spec/factories/users.rb
FactoryBot.define do
  factory :user do
    sequence(:name) { |n| "User #{n}" }
    sequence(:email) { |n| "user#{n}@example.com" }
    password { 'password' }
    password_confirmation { 'password' }
    activated { true }
    activated_at { Time.zone.now }

    # trait: バリエーション
    trait :unactivated do
      activated { false }
      activated_at { nil }
    end

    trait :with_avatar do
      after(:build) do |user|
        user.avatar.attach(
          io: File.open(Rails.root.join('spec/fixtures/files/avatar.png')),
          filename: 'avatar.png',
          content_type: 'image/png'
        )
      end
    end
  end
end

# 使用例
user = build(:user)                    # インスタンス生成（DB保存なし）
user = create(:user)                   # インスタンス生成 + DB保存
user = build_stubbed(:user)            # スタブ（DB接続なし、高速）
user = create(:user, :unactivated)     # trait 使用
user = create(:user, :with_avatar)
user = create(:user, name: 'Custom')   # 属性上書き
```

## コメント規約

### ドキュメントコメント (YARD 形式)

```ruby
# ✅ 良い例: YARD ドキュメント
# タスクを作成する
#
# @param data [Hash] 作成するタスクのデータ
# @option data [String] :title タスクのタイトル（必須）
# @option data [String] :description タスクの説明（任意）
# @option data [Integer] :assignee_id 担当者ID（任意）
# @return [Task] 作成されたタスク
# @raise [ValidationError] データが不正な場合
# @raise [DatabaseError] データベースエラーの場合
#
# @example
#   task = create_task(
#     title: '新しいタスク',
#     description: 'タスクの説明',
#     assignee_id: 1
#   )
def create_task(data)
  # 実装
end
```

### インラインコメント

```ruby
# ✅ 良い例: 意図を説明するコメント
class User < ApplicationRecord
  # メールアドレスを小文字に正規化
  # 大文字小文字を区別しないため
  before_save :downcase_email

  # アクティベーション用のトークンとダイジェストを生成
  before_create :create_activation_digest

  def password_reset_expired?
    # パスワードリセットは2時間で期限切れ
    reset_sent_at < 2.hours.ago
  end

  private

  # キャッシュを無効化して最新のユーザー情報を取得
  def reload_user_data
    user.reload
  end
end

# ✅ TODO・FIXME の活用
# TODO: キャッシュ機能を実装 (Issue #123)
# FIXME: 大量データでパフォーマンス劣化 (Issue #456)
# HACK: 一時的な回避策、後でリファクタリング必要
# NOTE: この実装はRails 7.0以降でのみ動作

# ❌ 悪い例: コードの内容を繰り返すだけ
# iを1増やす
i += 1

# ❌ 悪い例: コメントアウトされたコード（削除すべき）
# def old_implementation
#   # ...
# end
```

## セキュリティ

### 入力検証

```ruby
# ✅ 良い例: 厳密な検証
class User < ApplicationRecord
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d-]+(\.[a-z\d-]+)*\.[a-z]+\z/i

  validates :email,
            presence: true,
            format: { with: VALID_EMAIL_REGEX },
            uniqueness: { case_sensitive: false },
            length: { maximum: 255 }

  validates :name,
            presence: true,
            length: { maximum: 50 }

  # カスタム検証: XSS対策
  validate :name_must_not_contain_html

  private

  def name_must_not_contain_html
    return if name.blank?

    if name != ActionController::Base.helpers.sanitize(name, tags: [])
      errors.add(:name, 'HTMLタグは使用できません')
    end
  end
end
```

### Strong Parameters（再掲）

```ruby
# ✅ 良い例: ホワイトリスト方式
def user_params
  params.require(:user).permit(:name, :email, :password, :password_confirmation)
end

# ❌ 悪い例: すべて許可
def user_params
  params.require(:user).permit!  # 危険！admin属性なども変更可能になる
end
```

### SQL インジェクション対策

```ruby
# ✅ 良い例: プレースホルダー使用
User.where('name = ? AND email = ?', params[:name], params[:email])
User.where(name: params[:name], email: params[:email])

# ❌ 悪い例: 文字列補間（SQL インジェクションの危険）
User.where("name = '#{params[:name]}'")  # 危険！
```

### 認証・認可

```ruby
# ✅ 良い例: before_action で認証チェック
class RecordsController < ApplicationController
  before_action :logged_in_user, except: %i[show index]
  before_action :correct_user, only: %i[edit update destroy]

  private

  def logged_in_user
    return if logged_in?

    flash[:alert] = 'ログインしてください'
    redirect_to login_url, status: :see_other
  end

  def correct_user
    @record = Record.find(params[:id])
    return if current_user?(@record.user)

    redirect_to root_path, alert: '不正なアクセスです', status: :see_other
  end
end
```

### 機密情報の管理

```ruby
# ✅ 良い例: Rails credentials を使用
# rails credentials:edit で編集
openai_key = Rails.application.credentials.openai[:secret_key]
google_client_id = Rails.application.credentials.gcp[:client_id]

# 環境変数も可
database_url = ENV['DATABASE_URL']

# ❌ 悪い例: ハードコード
api_key = 'sk-1234567890abcdef'  # 絶対にしない！
```

## パフォーマンス

### N+1 クエリ対策

```ruby
# ✅ 良い例: includes で eager loading
# N+1 を防ぐ
@records = Record.includes(:user, :ramen_shop).recent.limit(20)

# ビューで使用
@records.each do |record|
  record.user.name         # 追加クエリなし
  record.ramen_shop.name   # 追加クエリなし
end

# joins と preload
@records = Record.joins(:user).where(users: { activated: true })
@records = Record.preload(:line_statuses).recent

# ❌ 悪い例: N+1 クエリ
@records = Record.recent.limit(20)
@records.each do |record|
  record.user.name         # 毎回クエリ実行！
  record.ramen_shop.name   # 毎回クエリ実行！
end
```

### クエリの最適化

```ruby
# ✅ 良い例: select で必要なカラムのみ取得
User.select(:id, :name, :email).where(activated: true)

# ✅ 良い例: pluck で配列取得（メモリ効率が良い）
user_ids = User.where(activated: true).pluck(:id)
user_emails = User.pluck(:email)

# ✅ 良い例: exists? で存在確認（count より高速）
User.where(email: email).exists?

# ❌ 悪い例: count で存在確認
User.where(email: email).count > 0  # 遅い

# ✅ 良い例: find_each でバッチ処理
User.find_each(batch_size: 1000) do |user|
  # メモリ効率的な処理
end

# ❌ 悪い例: all で全件読み込み
User.all.each do |user|  # メモリ大量消費
  # 処理
end
```

### キャッシュ

```ruby
# ✅ 良い例: ビューキャッシュ
# app/views/records/_record.html.erb
<% cache record do %>
  <div class="record">
    <%= record.comment %>
  </div>
<% end %>

# ✅ 良い例: Low-level キャッシュ
def expensive_calculation
  Rails.cache.fetch("user-#{id}-stats", expires_in: 1.hour) do
    # 重い計算
    calculate_statistics
  end
end
```

### データベースインデックス

```ruby
# ✅ 良い例: マイグレーションでインデックス追加
class AddIndexToRecords < ActiveRecord::Migration[7.0]
  def change
    # 単一カラムインデックス
    add_index :records, :user_id
    add_index :records, :ramen_shop_id

    # 複合インデックス
    add_index :records, [:user_id, :created_at]

    # ユニークインデックス
    add_index :users, :email, unique: true
  end
end
```

## リファクタリング

### マジックナンバーの排除

```ruby
# ✅ 良い例: 定数を定義
class Record < ApplicationRecord
  MAX_RETRY_COUNT = 3
  RETRY_DELAY_SECONDS = 5
  AUTO_RETIRE_HOURS = 24

  def retry_with_backoff
    MAX_RETRY_COUNT.times do |i|
      return true if process_record

      sleep(RETRY_DELAY_SECONDS * (i + 1)) if i < MAX_RETRY_COUNT - 1
    end

    false
  end
end

# ❌ 悪い例: マジックナンバー
def retry_with_backoff
  3.times do |i|
    return true if process_record

    sleep(5 * (i + 1)) if i < 2  # 3と2の関係が不明瞭
  end

  false
end
```

### メソッドの抽出

```ruby
# ✅ 良い例: メソッドを抽出して読みやすく
class Order < ApplicationRecord
  def process
    validate_order
    calculate_total
    apply_discounts
    save_order
  end

  private

  def validate_order
    raise ValidationError, '商品が選択されていません' if items.empty?
    raise ValidationError, '配送先が未設定です' if shipping_address.blank?
  end

  def calculate_total
    self.subtotal = items.sum { |item| item.price * item.quantity }
    self.tax = subtotal * 0.1
    self.total = subtotal + tax
  end

  def apply_discounts
    return unless coupon.present?

    self.discount = total * coupon.discount_rate
    self.total -= discount
  end

  def save_order
    save!
  end
end

# ❌ 悪い例: 長いメソッド
def process
  raise ValidationError, '商品が選択されていません' if items.empty?
  raise ValidationError, '配送先が未設定です' if shipping_address.blank?

  self.subtotal = items.sum { |item| item.price * item.quantity }
  self.tax = subtotal * 0.1
  self.total = subtotal + tax

  if coupon.present?
    self.discount = total * coupon.discount_rate
    self.total -= discount
  end

  save!
end
```

### Concern の活用

```ruby
# ✅ 良い例: 共通機能を Concern に抽出
# app/models/concerns/favoritable.rb
module Favoritable
  extend ActiveSupport::Concern

  included do
    has_many :favorites, as: :favoritable, dependent: :destroy
  end

  def favorited_by?(user)
    favorites.exists?(user: user)
  end

  def favorites_count
    favorites.count
  end
end

# 使用
class RamenShop < ApplicationRecord
  include Favoritable
end

class Record < ApplicationRecord
  include Favoritable
end
```

## チェックリスト

実装完了前に確認:

### コード品質
- [ ] 命名が明確で一貫している（snake_case, PascalCase）
- [ ] メソッドが単一の責務を持っている
- [ ] マジックナンバーがない（定数化されている）
- [ ] コメントが適切に記載されている
- [ ] エラーハンドリングが実装されている

### Rails 規約
- [ ] モデルに適切な Validations がある
- [ ] モデルに適切な Associations がある
- [ ] コントローラーで Strong Parameters を使用している
- [ ] before_action が適切に設定されている
- [ ] Flash メッセージと適切なステータスコードを使用している

### セキュリティ
- [ ] 入力検証が実装されている
- [ ] Strong Parameters でホワイトリスト方式を使用
- [ ] SQLインジェクション対策がされている（プレースホルダー使用）
- [ ] 機密情報がハードコードされていない（credentials 使用）
- [ ] 認証・認可が適切に実装されている

### パフォーマンス
- [ ] N+1 クエリがない（includes, preload, joins 使用）
- [ ] 適切なインデックスが設定されている
- [ ] 不要なカラムを取得していない（select, pluck 活用）
- [ ] バッチ処理で find_each を使用している

### テスト
- [ ] Model spec が書かれている（validations, associations, methods）
- [ ] Request spec が書かれている（成功/失敗ケース）
- [ ] テストがパスする
- [ ] エッジケースがカバーされている
- [ ] FactoryBot を適切に使用している

### ツール
- [ ] RuboCop エラーがない（`docker compose exec app bundle exec rubocop`）
- [ ] RSpec テストがパスする（`docker compose exec app bundle exec rspec`）
- [ ] コーディング規約に準拠している（.rubocop.yml）

### ドキュメント
- [ ] 複雑なロジックにコメントがある
- [ ] TODO や FIXME が適切に記載されている（該当する場合）
- [ ] Public メソッドに YARD コメントがある（該当する場合）
