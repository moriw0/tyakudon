class ShopRegisterRequest < ApplicationRecord
  belongs_to :user

  enum status: {
    open: 0,
    approved: 1,
    rejected: 2,
    completed: 3
  }
end
