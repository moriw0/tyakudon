class RamenShop < ApplicationRecord
  geocoded_by :address
  after_validation :geocode, if: :address_changed?

  has_many :records, dependent: :destroy
  has_many :favorites, dependent: :destroy
  has_many :favorite_users, through: :favorites, source: :user

  validates :name, presence: true, uniqueness: { scope: :address }
  validates :address, presence: true
  validates :latitude, numericality: { greater_than_or_equal_to: -90, less_than_or_equal_to: 90 }, allow_blank: true
  validates :longitude, numericality: { greater_than_or_equal_to: -180, less_than_or_equal_to: 180 }, allow_blank: true

  def self.ransackable_attributes(_auth_object = nil)
    ['name']
  end

  def favorited_by?(user)
    favorite_users.include?(user)
  end
end
