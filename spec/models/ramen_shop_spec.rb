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
      expect(ramen_shop.errors[:name]).to include('店名を入力してください。')
    end

    it 'validates presence of address' do
      ramen_shop.address = nil
      ramen_shop.valid?
      expect(ramen_shop.errors[:address]).to include('住所を入力してください。')
    end

    it 'validates uniqueness of name scoped to address' do
      existing_shop = create(:ramen_shop)
      ramen_shop.name = existing_shop.name
      ramen_shop.address = existing_shop.address
      ramen_shop.valid?
      expect(ramen_shop.errors[:name]).to include('店名がすでに使用されています。')
    end

    it 'validates numericality of latitude' do
      ramen_shop.latitude = 91
      ramen_shop.valid?
      expect(ramen_shop.errors[:latitude]).to include('緯度は90以下の値にしてください')
    end

    it 'validates numericality of longitude' do
      ramen_shop.longitude = 181
      ramen_shop.valid?
      expect(ramen_shop.errors[:longitude]).to include('経度は180以下の値にしてください')
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

      it 'is favorited by user' do
        expect(ramen_shop).to be_favorited_by(user)
      end
    end

    context 'when the user has not favorited the ramen shop' do
      it 'is not favorited by user' do
        expect(ramen_shop).to_not be_favorited_by(user)
      end
    end
  end

  describe '.order_by_records_count' do
    let!(:shop_with_many_records) { create(:ramen_shop, :many_shops) }
    let!(:shop_with_no_records)   { create(:ramen_shop, :many_shops) }
    let!(:shop_with_few_records)  { create(:ramen_shop, :many_shops) }

    before do
      create_list(:record, 5, ramen_shop: shop_with_many_records)
      create_list(:record, 2, ramen_shop: shop_with_few_records)
    end

    it 'returns shops ordered by records count descending' do
      result = described_class.order_by_records_count.to_a
      expect(result.first).to eq shop_with_many_records
      expect(result.last).to eq shop_with_no_records
    end

    context 'when some records are auto_retired' do
      let!(:shop_with_auto_retired) { create(:ramen_shop, :many_shops) }

      before do
        create_list(:record, 10, ramen_shop: shop_with_auto_retired, auto_retired: true)
      end

      it 'excludes auto_retired records from count' do
        result = described_class.order_by_records_count.to_a
        expect(result.index(shop_with_auto_retired)).to be > result.index(shop_with_few_records)
      end

      it 'does not rank shop_with_auto_retired above shop_with_few_records' do
        result = described_class.order_by_records_count.to_a
        expect(result.index(shop_with_few_records)).to be < result.index(shop_with_auto_retired)
      end
    end

    context 'when all records of a shop are auto_retired' do
      let!(:shop_all_retired) { create(:ramen_shop, :many_shops) }

      before do
        create_list(:record, 3, ramen_shop: shop_all_retired, auto_retired: true)
      end

      it 'counts the shop as having 0 active records' do
        result = described_class.order_by_records_count.to_a
        expect(result.index(shop_all_retired)).to be > result.index(shop_with_few_records)
      end

      it 'still includes the shop in results (LEFT JOIN maintained)' do
        result = described_class.order_by_records_count.to_a
        expect(result).to include(shop_all_retired)
      end
    end

    it 'includes shops with no records in results (LEFT JOIN maintained)' do
      result = described_class.order_by_records_count.to_a
      expect(result).to include(shop_with_no_records)
    end
  end

  describe '#active_records_count' do
    let(:ramen_shop) { create(:ramen_shop) }

    it 'counts only active records with wait_time' do
      create(:record, ramen_shop: ramen_shop, auto_retired: false, is_test: false, wait_time: 600)
      create(:record, ramen_shop: ramen_shop, auto_retired: false, is_test: false, wait_time: 900)
      expect(ramen_shop.active_records_count).to eq(2)
    end

    it 'excludes auto_retired records' do
      create(:record, ramen_shop: ramen_shop, auto_retired: false, is_test: false, wait_time: 600)
      create(:record, ramen_shop: ramen_shop, auto_retired: true, is_test: false, wait_time: 900)
      expect(ramen_shop.active_records_count).to eq(1)
    end

    it 'excludes test records' do
      create(:record, ramen_shop: ramen_shop, auto_retired: false, is_test: false, wait_time: 600)
      create(:record, ramen_shop: ramen_shop, auto_retired: false, is_test: true, wait_time: 900)
      expect(ramen_shop.active_records_count).to eq(1)
    end

    it 'excludes records with nil wait_time' do
      create(:record, ramen_shop: ramen_shop, auto_retired: false, is_test: false, wait_time: 600)
      create(:record, ramen_shop: ramen_shop, auto_retired: false, is_test: false, wait_time: nil)
      expect(ramen_shop.active_records_count).to eq(1)
    end

    it 'returns 0 when no active records exist' do
      expect(ramen_shop.active_records_count).to eq(0)
    end

    context 'when records are loaded' do
      it 'uses in-memory filtering' do
        create(:record, ramen_shop: ramen_shop, auto_retired: false, is_test: false, wait_time: 600)
        ramen_shop.records.load
        expect(ramen_shop.records).to be_loaded
        expect(ramen_shop.active_records_count).to eq(1)
      end
    end
  end

  describe '#average_wait_time' do
    let(:ramen_shop) { create(:ramen_shop) }

    it 'returns the average wait_time of active records' do
      create(:record, ramen_shop: ramen_shop, auto_retired: false, is_test: false, wait_time: 600)
      create(:record, ramen_shop: ramen_shop, auto_retired: false, is_test: false, wait_time: 900)
      expect(ramen_shop.average_wait_time).to eq(750.0)
    end

    it 'returns nil when no active records exist' do
      expect(ramen_shop.average_wait_time).to be_nil
    end

    it 'excludes auto_retired records from average' do
      create(:record, ramen_shop: ramen_shop, auto_retired: false, is_test: false, wait_time: 600)
      create(:record, ramen_shop: ramen_shop, auto_retired: true, is_test: false, wait_time: 9000)
      expect(ramen_shop.average_wait_time).to eq(600.0)
    end

    it 'excludes test records from average' do
      create(:record, ramen_shop: ramen_shop, auto_retired: false, is_test: false, wait_time: 600)
      create(:record, ramen_shop: ramen_shop, auto_retired: false, is_test: true, wait_time: 9000)
      expect(ramen_shop.average_wait_time).to eq(600.0)
    end

    it 'excludes records with nil wait_time' do
      create(:record, ramen_shop: ramen_shop, auto_retired: false, is_test: false, wait_time: 600)
      create(:record, ramen_shop: ramen_shop, auto_retired: false, is_test: false, wait_time: nil)
      expect(ramen_shop.average_wait_time).to eq(600.0)
    end

    context 'when records are loaded' do
      it 'uses in-memory calculation' do
        create(:record, ramen_shop: ramen_shop, auto_retired: false, is_test: false, wait_time: 300)
        create(:record, ramen_shop: ramen_shop, auto_retired: false, is_test: false, wait_time: 900)
        ramen_shop.records.load
        expect(ramen_shop.records).to be_loaded
        expect(ramen_shop.average_wait_time).to eq(600.0)
      end
    end
  end

  describe 'search_by_keywords' do
    let!(:tokyo_ramen_shop) { create(:ramen_shop, name: 'Tokyo Ramen', address: 'Tokyo') }
    let!(:osaka_ramen_shop) { create(:ramen_shop, name: 'Osaka Ramen', address: 'Osaka') }

    context 'when query_params is present' do
      it 'returns shops matching the keywords' do
        search = described_class.search_by_keywords({ name_or_address_cont: 'Tokyo' })
        expect(search.result).to include(tokyo_ramen_shop)
        expect(search.result).to_not include(osaka_ramen_shop)
      end
    end

    context 'when query_params is nil' do
      it 'returns all shops' do
        search = described_class.search_by_keywords(nil)
        expect(search.result).to include(tokyo_ramen_shop, osaka_ramen_shop)
      end
    end
  end
end
