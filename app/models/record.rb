class Record < ApplicationRecord
  belongs_to :user
  belongs_to :ramen_shop
  has_many :line_statuses, dependent: :destroy
  has_one_attached :image
  accepts_nested_attributes_for :line_statuses

  default_scope -> { order(created_at: :desc) }

  validates :comment, length: { maximum: 140 }
  validates :image, content_type: { in: %i[png jpg jpeg],
                                    message: 'のフォーマットが不正です' },
                    size:         { less_than_or_equal_to: 5.megabytes,
                                    message: 'は5MB以下である必要があります' }

end
