class Record < ApplicationRecord
  belongs_to :user
  belongs_to :ramen_shop
  has_many :line_statuses, dependent: :destroy
  has_one_attached :image do |attachable|
    attachable.variant :display, resize_to_limit: [750, 750]
  end
  accepts_nested_attributes_for :line_statuses

  scope :not_retired, -> { where(is_retired: false, auto_retired: false).where.not(wait_time: nil) }
  scope :active, -> { where(auto_retired: false).where.not(wait_time: nil) }
  scope :ordered_by_wait_time, -> { order('wait_time DESC') }
  scope :ordered_by_created_at, -> { order('created_at DESC') }
  scope :active_ordered, -> { active.ordered_by_created_at }
  scope :top_five, -> { limit(5) }

  validates :comment, length: { maximum: 140 }
  validates :image, content_type: { in: %i[png jpg jpeg],
                                    message: 'のフォーマットが不正です' },
                    size: { less_than_or_equal_to: 5.megabytes,
                            message: 'は5MB以下である必要があります' }
  validate :started_at_is_recent, on: :create, unless: :skip_validations
  after_create :schedule_auto_retire

  attr_accessor :skip_validations

  def self.ranking_records
    not_retired.ordered_by_wait_time
  end

  def self.new_records
    not_retired.ordered_by_created_at
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

  def started_at_is_recent
    if started_at && (started_at - Time.current).abs > 5.seconds
      errors.add(:started_at, 'は作成時の現在時刻より数秒以内でなければなりません')
    end
  end

  def ended_at_is_recent
    errors.add(:ended_at, 'は現在時刻より数秒前である必要があります。') unless ended_at && ended_at >= Time.now - 5.seconds
  end

  def ended_at_is_after_started_at
    errors.add(:ended_at, 'はstarted_atより後である必要があります。') if ended_at && started_at && ended_at <= started_at
  end

  def wait_time_is_correct
    calculated_wait_time = (ended_at - started_at)
    errors.add(:wait_time, 'はended_atとstarted_atの差である必要があります。') unless wait_time && (wait_time - calculated_wait_time).abs <= 0.01
  end
end
