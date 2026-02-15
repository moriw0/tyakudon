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
  scope :with_associations, -> { preload(:records) }
  scope :order_by_records_count, -> {
    left_joins(:records)
      .group(:id)
      .order(Arel.sql('COUNT(CASE WHEN records.auto_retired = false THEN records.id END) DESC'))
  }

  def self.ransackable_attributes(_auth_object = nil)
    %w[name address]
  end

  def self.ransackable_associations(_auth_object = nil)
    []
  end

  def self.search_by_keywords(query_params)
    return RamenShop.ransack unless query_params

    keywords = query_params[:name_or_address_cont].split(/[\p{blank}\s]+/)
    grouping_hash = keywords.reduce({}) do |hash, word|
      hash.merge(word => { name_or_address_cont: word })
    end

    search = RamenShop.ransack(combinator: 'and', groupings: grouping_hash)
    search.sorts = 'id desc' if search.sorts.empty?
    search
  end

  def favorited_by?(user)
    favorite_users.include?(user)
  end

  def last_active_record
    if records.loaded?
      records.reverse.find { |r| !r.auto_retired && !r.is_test && r.wait_time.present? }
    else
      records.active_ordered.first
    end
  end

  def active_records_count
    if records.loaded?
      records.count { |r| !r.auto_retired && !r.is_test && r.wait_time.present? }
    else
      records.active.count
    end
  end

  def average_wait_time
    if records.loaded?
      active = records.select { |r| !r.auto_retired && !r.is_test && r.wait_time.present? }
      return nil if active.empty?

      active.sum(&:wait_time) / active.size.to_f
    else
      records.active.average(:wait_time)&.to_f
    end
  end
end
