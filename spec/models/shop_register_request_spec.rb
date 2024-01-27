require 'rails_helper'

RSpec.describe ShopRegisterRequest do
  let!(:user) { create(:user) }

  context 'with valid attributes' do
    let!(:request) { build(:shop_register_request, user: user) }

    it 'is valid' do
      expect(request).to be_valid
    end
  end

  context 'with invalid attributes' do
    context 'without a name' do
      let!(:request) { build(:shop_register_request, user: user, name: nil) }

      it 'includes error message' do
        request.valid?
        expect(request.errors[:name]).to include '店名を入力してください。'
      end
    end

    context 'without an address' do
      let!(:request) { build(:shop_register_request, user: user, address: nil) }

      it 'includes error message' do
        request.valid?
        expect(request.errors[:address]).to include '住所を入力してください。'
      end
    end

    context 'with a duplicate name and address' do
      let!(:request) { build(:shop_register_request, user: user, name: 'よくある店舗', address: '東京都新宿区') }

      before do
        create(:shop_register_request, user: user, name: 'よくある店舗', address: '東京都新宿区')
      end

      it 'includes error message' do
        request.valid?
        expect(request.errors[:name]).to include '店名がすでに使用されています。'
      end
    end

    context 'with a name longer than 100 characters' do
      let!(:long_name) { 'a' * 101 }
      let!(:request) { build(:shop_register_request, user: user, name: long_name) }

      it 'includes error message' do
        request.valid?
        expect(request.errors[:name]).to include '店名は100文字以内で入力してください。'
      end
    end

    context 'with an address longer than 255 characters' do
      let!(:long_address) { 'a' * 256 }
      let!(:request) { build(:shop_register_request, user: user, address: long_address) }

      it 'includes error message' do
        request.valid?
        expect(request.errors[:address]).to include '住所は255文字以内で入力してください。'
      end
    end
  end

  describe 'after_initialize' do
    let!(:request) { described_class.new }

    it 'is initialized with a status of open' do
      expect(request.status).to eq('open')
    end
  end
end
