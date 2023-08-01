class LineStatus < ApplicationRecord
  belongs_to :record
  has_one_attached :image do |attachable|
    attachable.variant :display, resize_to_limit: [250, 250]
  end

  enum line_type: { inside_the_store: 1, outside_the_store: 2, seated: 3 }

  validates :line_number, numericality: { only_integer: true, greater_than_or_equal_to: 0 }, unless: :seated?
  validates :comment, length: { maximum: 140, too_long: '最大%<count>s文字まで使えます' }
  validates :image, content_type: { in: %i[png jpg jpeg],
                                    message: 'のフォーマットが不正です' },
                    size: { less_than_or_equal_to: 5.megabytes,
                            message: 'は5MB以下である必要があります' }
end
