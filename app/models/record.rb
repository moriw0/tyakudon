class Record < ApplicationRecord
  belongs_to :user
  belongs_to :ramen_shop
  has_many :line_statuses, dependent: :destroy
  accepts_nested_attributes_for :line_statuses

  default_scope -> { order(created_at: :desc) }

  validates :comment, length: { maximum: 140 }

  def calculate_wait_time!
    ended_at = Time.current
    wait_time = ended_at - started_at
    update!(
      ended_at: ended_at,
      wait_time: wait_time
    )
  end
end
