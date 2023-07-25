class RamenShop < ApplicationRecord
  geocoded_by :address
  after_validation :geocode

  has_many :records, dependent: :destroy
  has_many :favorites, dependent: :destroy
  has_many :favorite_users, through: :favorites, source: :user

  def self.ransackable_attributes(_auth_object = nil)
    ['name']
  end

  def favorited_by?(user)
    favorite_users.include?(user)
  end
end
