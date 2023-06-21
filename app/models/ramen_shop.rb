class RamenShop < ApplicationRecord
  geocoded_by :address
  after_validation :geocode
  has_many :records

  def self.ransackable_attributes(_auth_object = nil)
    ['name']
  end
end
