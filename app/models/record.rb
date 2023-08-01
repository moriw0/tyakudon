class Record < ApplicationRecord
  belongs_to :user
  belongs_to :ramen_shop
  has_many :line_statuses, dependent: :destroy
  has_one_attached :image do |attachable|
    attachable.variant :display, resize_to_limit: [250, 250]
  end
  accepts_nested_attributes_for :line_statuses

  default_scope -> { order(created_at: :desc) }

  validates :comment, length: { maximum: 140 }
  validates :image, content_type: { in: %i[png jpg jpeg],
                                    message: 'のフォーマットが不正です' },
                    size: { less_than_or_equal_to: 5.megabytes,
                            message: 'は5MB以下である必要があります' }

  def calculate_wait_time_for_retire!
    update!(is_retired: true,
            ended_at: Time.current,
            wait_time: Time.current - started_at)
  end
end
