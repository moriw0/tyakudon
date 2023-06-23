require 'rails_helper'

RSpec.describe RamenShop do
  it 'is valid with name, address, latitude and longitude' do
    ramen_shop = described_class.new(
      name: '家系らーめん 武将家 外伝',
      address: '〒101-0023 東京都千代田区神田松永町16',
      latitude: 35.7000396,
      longitude: 139.7752222
    )
    expect(ramen_shop).to be_valid
  end

  it 'is valid with Bot' do
    ramen_shop = create(:ramen_shop)
    expect(ramen_shop).to be_valid
  end
end
