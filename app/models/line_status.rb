class LineStatus < ApplicationRecord
  belongs_to :record
  enum line_type: { inside_the_store: 1, outside_the_store: 2, other: 3 }

  validates :line_number, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :comment, length: { maximum: 200, too_long: "最大%{count}文字まで使えます" }
end
