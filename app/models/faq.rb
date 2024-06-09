class Faq < ApplicationRecord
  validates :question, presence: true
  validates :answer, presence: true
  has_rich_text :detail
end
