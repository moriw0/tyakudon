class Record < ApplicationRecord
  belongs_to :ramen_shop
  has_many :line_statuses
  accepts_nested_attributes_for :line_statuses

  def calculate_wait_time!
    self.ended_at = Time.current
    self.wait_time = ended_at - started_at
    self
  end
end
