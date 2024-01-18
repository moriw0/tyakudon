require 'rails_helper'

RSpec.describe 'ShopRegisterRequests' do
  let!(:user) { create(:user) }

  before do
    log_in_as user
  end

  describe 'GET /new' do
    it 'returns http success' do
      get new_shop_register_request_path
      expect(response).to have_http_status(:success)
    end
  end

  describe 'POST /create' do
    context 'with valid parameters' do
      it 'creates a new ShopRegisterRequest' do
        expect {
          post shop_register_requests_path,
               params: { shop_register_request: { name: 'New Ramen Shop', address: '123 Ramen Street',
                                                  remarks: 'Great place!' } }
        }.to change(ShopRegisterRequest, :count).by(1)
        expect(response).to redirect_to(root_path)
      end
    end

    context 'with invalid parameters' do
      it 'does not create a new ShopRegisterRequest' do
        expect {
          post shop_register_requests_path, params: { shop_register_request: { name: '', address: '' } }
        }.to_not change(ShopRegisterRequest, :count)
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end

    context 'when shop already exists' do
      before do
        create(:ramen_shop, name: 'Existing Ramen Shop', address: '123 Ramen Street')
      end

      it 'does not create a new ShopRegisterRequest' do
        post shop_register_requests_path,
             params: { shop_register_request: { name: 'Existing Ramen Shop', address: '123 Ramen Street' } }
        expect(ShopRegisterRequest.count).to eq(0)
        expect(flash[:alert]).to eq '店舗が既に存在します。'
      end
    end
  end
end
