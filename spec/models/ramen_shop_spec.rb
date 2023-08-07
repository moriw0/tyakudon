require 'rails_helper'

RSpec.describe RamenShop do
  let(:ramen_shop) { build(:ramen_shop) }

  describe 'Validations' do
    it 'is valid with name, address, latitude and longitude' do
      ramen_shop = described_class.new(
        name: '家系らーめん 武将家 外伝',
        address: '〒101-0023 東京都千代田区神田松永町16',
        latitude: 35.7000396,
        longitude: 139.7752222
      )
      expect(ramen_shop).to be_valid
    end

    it 'validates presence of name' do
      ramen_shop.name = nil
      ramen_shop.valid?
      expect(ramen_shop.errors[:name]).to include("を入力してください")
    end

    it 'validates presence of address' do
      ramen_shop.address = nil
      ramen_shop.valid?
      expect(ramen_shop.errors[:address]).to include("を入力してください")
    end

    it 'validates uniqueness of name scoped to address' do
      existing_shop = create(:ramen_shop)
      ramen_shop.name = existing_shop.name
      ramen_shop.address = existing_shop.address
      ramen_shop.valid?
      expect(ramen_shop.errors[:name]).to include("はすでに存在します")
    end

    it 'validates numericality of latitude' do
      ramen_shop.latitude = 91
      ramen_shop.valid?
      expect(ramen_shop.errors[:latitude]).to include("は90以下の値にしてください")
    end

    it 'validates numericality of longitude' do
      ramen_shop.longitude = 181
      ramen_shop.valid?
      expect(ramen_shop.errors[:longitude]).to include("は180以下の値にしてください")
    end
  end

  describe 'Associations' do
    it 'has many records' do
      expect(ramen_shop).to respond_to(:records)
    end

    it 'has many favorites' do
      expect(ramen_shop).to respond_to(:favorites)
    end

    it 'has many favorite_users through favorites' do
      expect(ramen_shop).to respond_to(:favorite_users)
    end
  end

  describe '#favorited_by?' do
    let(:ramen_shop) { create(:ramen_shop) }
    let(:user) { create(:user) }

    context 'when the user has favorited the ramen shop' do
      before do
        ramen_shop.favorites.create(user: user)
        ramen_shop.reload
      end

      it 'returns true' do
        expect(ramen_shop.favorited_by?(user)).to be_truthy
      end
    end

    context 'when the user has not favorited the ramen shop' do
      it 'returns false' do
        expect(ramen_shop.favorited_by?(user)).to be_falsey
      end
    end
  end
end
