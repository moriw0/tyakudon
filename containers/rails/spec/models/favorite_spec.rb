require 'rails_helper'

RSpec.describe Favorite do
  let(:user) { create(:user) }
  let(:ramen_shop) { create(:ramen_shop) }

  it 'is valid with user and ramen_shop' do
    favorite = user.favorites.build(ramen_shop: ramen_shop)
    expect(favorite).to be_valid
  end

  it 'is invalid without ramen_shop' do
    favorite = user.favorites.build(ramen_shop: nil)
    favorite.valid?
    expect(favorite.errors[:ramen_shop]).to include 'を入力してください'
  end

  it 'is invalid without user' do
    favorite = described_class.new(ramen_shop: ramen_shop, user: nil)
    favorite.valid?
    expect(favorite.errors[:user]).to include 'を入力してください'
  end
end
