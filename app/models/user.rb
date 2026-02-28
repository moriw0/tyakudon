# rubocop:disable Metrics/ClassLength
class User < ApplicationRecord
  attr_accessor :remember_token, :activation_token, :reset_token

  has_many :records, dependent: :restrict_with_exception
  has_many :favorites, dependent: :restrict_with_exception
  has_many :favorite_shops, through: :favorites, source: :ramen_shop
  has_many :likes, dependent: :restrict_with_exception
  has_many :like_records, through: :likes, source: :record
  has_many :shop_register_requests, dependent: :destroy
  has_one_attached :avatar

  before_save :downcase_email
  before_create :create_activation_digest

  validates :name,  presence: true, length: { maximum: 50 }
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d-]+(\.[a-z\d-]+)*\.[a-z]+\z/i
  validates :email, presence: true, length: { maximum: 255 },
                    format: { with: VALID_EMAIL_REGEX },
                    uniqueness: true

  has_secure_password validations: false
  validate :validate_password_unless_uid, unless: :uid?
  validates :password, length: { maximum: ActiveModel::SecurePassword::MAX_PASSWORD_LENGTH_ALLOWED, unless: :uid? }
  validates :password, confirmation: { allow_blank: true, unless: :uid? }
  validates :password, presence: true, length: { minimum: 6 }, allow_nil: true, unless: :uid?

  validates :avatar, content_type: { in: %i[png jpg jpeg],
                                     message: :file_type_invalid },
                     size: { less_than_or_equal_to: 9.megabytes,
                             message: :file_size_exceed }

  def self.digest(string)
    cost = if ActiveModel::SecurePassword.min_cost
             BCrypt::Engine::MIN_COST
           else
             BCrypt::Engine.cost
           end
    BCrypt::Password.create(string, cost: cost)
  end

  def self.new_token
    SecureRandom.urlsafe_base64
  end

  def build_with_omniauth(auth)
    assign_attributes(
      provider: auth['provider'],
      uid: auth['uid'],
      email: auth['info']['email']
    )
  end

  # rubocop:disable Rails/SkipsModelValidations
  def remember
    self.remember_token = User.new_token
    update_attribute(:remember_digest, User.digest(remember_token))
    remember_digest
  end

  def forget
    update_attribute(:remember_digest, nil)
  end

  def forget_reset_digest
    update_attribute(:reset_digest, nil)
  end

  def activate
    update_columns(activated: true, activated_at: Time.zone.now)
  end

  def create_reset_digest
    self.reset_token = User.new_token
    update_columns(reset_digest: User.digest(reset_token), reset_sent_at: Time.zone.now)
  end
  # rubocop:enable Rails/SkipsModelValidations

  def session_token
    remember_digest || remember
  end

  def authenticated?(attribute, token)
    digest = send("#{attribute}_digest")
    return false if digest.nil?

    BCrypt::Password.new(digest).is_password?(token)
  end

  def send_activation_email
    UserMailer.account_activation(self).deliver_now
  end

  def send_password_reset_email
    UserMailer.password_reset(self).deliver_now
  end

  def password_reset_expired?
    reset_sent_at < 2.hours.ago
  end

  def favorites?(shop)
    favorite_shops.include?(shop)
  end

  def add_favorite(shop)
    favorite_shops << shop unless favorites?(shop)
  end

  def remove_favorite(shop)
    favorite_shops.delete(shop) if favorites?(shop)
  end

  def likes?(record)
    if like_records.loaded?
      # Use in-memory collection if already loaded
      like_records.include?(record)
    else
      # Use efficient query if not loaded
      likes.exists?(record_id: record.id)
    end
  end

  def add_like(record)
    like_records << record unless likes?(record)
  end

  def remove_like(record)
    like_records.delete(record) if likes?(record)
  end

  def unread_announcements?
    latest = Announcement.published.maximum(:published_at)
    return false if latest.nil?

    last_read_announcement_at.nil? || last_read_announcement_at < latest
  end

  private

  def downcase_email
    email.downcase!
  end

  def create_activation_digest
    self.activation_token = User.new_token
    self.activation_digest = User.digest(activation_token)
  end

  def validate_password_unless_uid
    errors.add(:password, :blank) if password_digest.blank?
  end
end
# rubocop:enable Metrics/ClassLength
