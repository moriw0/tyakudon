class Announcement < ApplicationRecord
  has_rich_text :body

  validates :title,        presence: true
  validates :published_at, presence: true

  scope :published, -> { where(published_at: ..Time.current) }
  scope :recent,    -> { order(published_at: :desc) }
end
