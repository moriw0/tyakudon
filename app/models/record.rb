class Record < ApplicationRecord
  belongs_to :ramen_shop

  def calculate_wait_time!
    self.ended_at = Time.current
    self.wait_time = self.ended_at - self.started_at
    self
  end
end
