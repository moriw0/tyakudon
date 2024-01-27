class ShopRegisterRequest < ApplicationRecord
  belongs_to :user

  enum status: {
    open: 0,
    approved: 1,
    rejected: 2,
    completed: 3
  }

  validates :name, presence: true, uniqueness: { scope: :address }, length: { maximum: 100 }
  validates :address, presence: true, length: { maximum: 255 }
end
