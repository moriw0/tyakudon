class Record < ApplicationRecord
  belongs_to :user
  belongs_to :ramen_shop
  has_many :line_statuses, dependent: :destroy
  has_one_attached :image do |attachable|
    attachable.variant :display, resize_to_limit: [750, 750]
  end
  accepts_nested_attributes_for :line_statuses

  scope :active_records, -> { where(is_retired: false, auto_retired: false).where.not(wait_time: nil) }
  scope :ordered_by_wait_time, -> { order('wait_time DESC') }
  scope :ordered_by_created_at, -> { order('created_at DESC') }
  scope :top_five, -> { limit(5) }

  validates :comment, length: { maximum: 140 }
  validates :image, content_type: { in: %i[png jpg jpeg],
                                    message: 'のフォーマットが不正です' },
                    size: { less_than_or_equal_to: 5.megabytes,
                            message: 'は5MB以下である必要があります' }
  after_create :schedule_auto_retire

  def self.ranking_records
    active_records.ordered_by_wait_time
  end

  def self.new_records
    active_records.ordered_by_created_at
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

  def schedule_auto_retire
    AutoRetireRecordJob.set(wait: 1.day).perform_later(self)
  end
end
