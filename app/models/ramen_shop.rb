class RamenShop < ApplicationRecord
  geocoded_by :address
  after_validation :geocode
  has_many :records
end
