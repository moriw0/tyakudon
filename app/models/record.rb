class Record < ApplicationRecord
  belongs_to :user
  belongs_to :ramen_shop
  has_many :line_statuses, dependent: :destroy
  has_one_attached :image do |attachable|
    attachable.variant :display, resize_to_limit: [750, 750]
  end
  has_many :likes, dependent: :destroy
  has_many :cheer_messages, dependent: :destroy
  accepts_nested_attributes_for :line_statuses

  attr_accessor :skip_validation, :calculate_action

  validates :comment, length: { maximum: 140 }
  validates :image, content_type: { in: %i[png jpg jpeg],
                                    message: :file_type_invalid },
                    size: { less_than_or_equal_to: 9.megabytes,
                            message: :file_size_exceed }
  validate :started_at_is_recent,         on: :create, unless: :skip_validation
  validate :ended_at_is_recent,           on: :update, if: :calculate_action
  validate :ended_at_is_after_started_at, on: :update
  validate :wait_time_is_correct,         on: :update

  before_create :set_is_test_based_on_user unless Rails.env.development?
  after_create :schedule_auto_retire

  scope :not_retired, -> { where(is_retired: false, auto_retired: false, is_test: false).where.not(wait_time: nil) }
  scope :active, -> { where(auto_retired: false, is_test: false).where.not(wait_time: nil) }
  scope :order_by_longest_wait, -> { order('wait_time DESC') }
  scope :order_by_shortest_wait, -> { order('wait_time ASC') }
  scope :ordered_by_created_at, -> { order('records.created_at DESC') }
  scope :active_ordered, -> { active.ordered_by_created_at }
  scope :top_five, -> { limit(5) }
  scope :with_associations, -> {
    eager_load(:user, :ramen_shop).preload(:line_statuses, :likes, image_attachment: :blob)
  }
  scope :order_by_most_likes, -> {
    likes_subquery = Like.group(:record_id).select('record_id, COUNT(id) AS likes_count')
    joins("LEFT JOIN (#{likes_subquery.to_sql}) likes_subquery ON likes_subquery.record_id = records.id")
      .select('records.*, likes_subquery.likes_count')
      .order('likes_subquery.likes_count DESC NULLS LAST')
  }

  def self.ranking_by(sort_type:, page:)
    case sort_type
    when 'shortest'
      not_retired.with_associations.order_by_shortest_wait.page(page)
    when 'most_likes'
      not_retired.with_associations.order_by_most_likes.page(page)
    else
      not_retired.with_associations.order_by_longest_wait.page(page)
    end
  end

  def self.new_records
    not_retired.ordered_by_created_at.with_associations
  end

  def self.favorite_records_from(user)
    favorite_shop_ids = 'SELECT ramen_shop_id FROM favorites WHERE user_id = :user_id'

    Record.where("ramen_shop_id IN (#{favorite_shop_ids})", user_id: user.id)
          .not_retired.ordered_by_created_at.with_associations
  end

  def self.filter_by_shop_ids(ids)
    Record.where(ramen_shop_id: ids).not_retired.ordered_by_created_at.with_associations
  end

  def calculate_wait_time_for_retire!
    update!(is_retired: true,
            ended_at: Time.current,
            wait_time: Time.current - started_at)
  end

  def auto_retire!
    update!(auto_retired: true)
  end

  private

  def set_is_test_based_on_user
    self.is_test = true if user.is_test_mode?
  end

  def schedule_auto_retire
    AutoRetireRecordJob.set(wait: 1.day).perform_later(self)
  end

  def started_at_is_recent
    return unless started_at && (started_at - Time.current).abs > 5.seconds

    errors.add(:started_at, :started_at_not_recent)
  end

  def ended_at_is_recent
    return unless ended_at && (ended_at - Time.current).abs > 5.seconds

    errors.add(:ended_at, :ended_at_not_recent)
  end

  def ended_at_is_after_started_at
    errors.add(:ended_at, :ended_at_before_started_at) if ended_at && started_at && ended_at <= started_at
  end

  def wait_time_is_correct
    return unless started_at && ended_at && wait_time

    return if wait_time_correct?

    errors.add(:wait_time, :incorrect_wait_time)
  end

  def wait_time_correct?
    calculated_wait_time = (ended_at - started_at)
    (wait_time - calculated_wait_time).abs <= 1
  end
end
