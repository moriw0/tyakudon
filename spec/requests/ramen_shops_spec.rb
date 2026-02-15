require 'rails_helper'

RSpec.describe 'RamenShops' do
  let(:ramen_shop) { create(:ramen_shop) }
  let(:non_admin) { create(:user, :other_user) }
  let(:admin) { create(:user, :admin) }

  shared_examples 'when not logged in' do
    it 'redirects to login_path' do
      do_request
      expect(response).to redirect_to login_path
    end
  end

  shared_examples 'as a non-admin' do
    it 'redirects to root_path' do
      log_in_as non_admin
      do_request
      expect(response).to redirect_to root_path
    end
  end

  describe 'GET /ramen_shops #index' do
    before { ramen_shop }

    it 'returns 200 OK without keyword' do
      get ramen_shops_path
      expect(response).to have_http_status(:ok)
    end

    it 'returns results filtered by keyword' do
      create(:ramen_shop, name: '特別なラーメン屋', address: '東京都新宿区')
      get ramen_shops_path, params: { q: { name_or_address_cont: '特別' } }
      expect(response.body).to include '特別なラーメン屋'
    end

    it 'returns JSON when requested' do
      get ramen_shops_path, as: :json
      expect(response).to have_http_status(:ok)
      expect(response.content_type).to include 'application/json'
    end
  end

  describe 'GET /ramen_shops/:id #show' do
    it 'returns 200 OK' do
      get ramen_shop_path(ramen_shop)
      expect(response).to have_http_status(:ok)
    end

    it 'returns JSON when requested' do
      get ramen_shop_path(ramen_shop), as: :json
      expect(response).to have_http_status(:ok)
      expect(response.content_type).to include 'application/json'
    end
  end

  describe 'GET /near_shops' do
    before { ramen_shop }

    it 'returns JSON with nearby shops' do
      get near_shops_path, params: { lat: ramen_shop.latitude, lng: ramen_shop.longitude }
      expect(response).to have_http_status(:ok)
      expect(response.content_type).to include 'application/json'
    end
  end

  describe 'GET /ramen_shops/new #new' do
    subject(:do_request) { get new_ramen_shop_path }

    it_behaves_like 'when not logged in'
    it_behaves_like 'as a non-admin'

    context 'with admin' do
      before { log_in_as admin }

      context 'without params' do
        it 'initializes a new RamenShop with empty attributes' do
          get new_ramen_shop_path
          ramen_shop = controller.instance_variable_get(:@ramen_shop)
          expect(ramen_shop.name).to be_nil
          expect(ramen_shop.address).to be_nil
        end
      end

      context 'with valid params' do
        it 'initializes a new RamenShop with pre-filled attributes' do
          get new_ramen_shop_path(request: { id: 1, name: 'リクエスト店', address: '東京都新宿区' })
          ramen_shop = controller.instance_variable_get(:@ramen_shop)
          expect(ramen_shop.name).to eq 'リクエスト店'
          expect(ramen_shop.address).to eq '東京都新宿区'
        end

        it 'includes request id in hidden field' do
          get new_ramen_shop_path(request: { id: 1, name: 'リクエスト店', address: '東京都新宿区' })
          expect(response.body).to include 'input type="hidden" name="request_id" id="request_id" value="1"'
        end
      end
    end
  end

  describe 'GET /ramen_shops/:id/edit #edit' do
    subject(:do_request) { get edit_ramen_shop_path(ramen_shop) }

    it_behaves_like 'when not logged in'
    it_behaves_like 'as a non-admin'

    it 'returns edit form when logged in as an admin' do
      log_in_as admin
      do_request
      expect(response.body).to include '<h1>店舗更新</h1>'
    end
  end

  describe 'POST /ramen_shops #create' do
    subject(:do_request) { post ramen_shops_path, params: ramen_shop_params }

    let(:ramen_shop_params) { { ramen_shop: attributes_for(:ramen_shop) } }

    it_behaves_like 'when not logged in'
    it_behaves_like 'as a non-admin'

    context 'with admin' do
      before { log_in_as admin }

      context ['with valid ramen_shop params', 'shop request'].join(', ') do
        subject(:do_request) { post ramen_shops_path, params: params_with_request }

        let(:params_with_request) do
          { ramen_shop: {
            name: 'リクエスト店',
            address: '東京都新宿区'
          }, request_id: 1 }
        end
        let(:request_id) { controller.instance_variable_get(:@request_id) }

        it 'creates ramen_shop' do
          expect {
            do_request
          }.to change(RamenShop, :count).by(1)
        end

        it 'redirectds to complete_shop_register_request_path' do
          do_request
          expect(response).to redirect_to complete_shop_register_request_path(1, ramen_shop_id: RamenShop.last.id)
        end

        it 'has a request_id' do
          do_request
          expect(request_id).to eq '1'
        end
      end

      context ['with invalid ramen_shop params', 'shop request'].join(', ') do
        subject(:do_request) { post ramen_shops_path, params: params_with_request }

        let(:params_with_request) do
          { ramen_shop: {
            name: '',
            address: ''
          }, request_id: 1 }
        end
        let(:request_id) { controller.instance_variable_get(:@request_id) }

        it 'does not create ramen_shop' do
          expect {
            do_request
          }.to_not change(RamenShop, :count)
        end

        it 'has a request_id' do
          do_request
          expect(request_id).to eq '1'
        end
      end

      context 'with valid params and no shop request' do
        it 'creates ramen_shop' do
          expect {
            do_request
          }.to change(RamenShop, :count).by(1)
        end

        it 'has a notice flash' do
          do_request
          expect(flash[:notice]).to eq 'saved!'
        end
      end
    end
  end

  describe 'PATCH /ramen_shops/:id #update' do
    subject(:do_request) { patch ramen_shop_path(ramen_shop), params: ramen_shop_params }

    let(:ramen_shop_params) { { ramen_shop: attributes_for(:ramen_shop, name: 'ラーメン店') } }

    it_behaves_like 'when not logged in'
    it_behaves_like 'as a non-admin'

    it 'updates ramen_shop when logged in as an admin' do
      log_in_as admin
      do_request
      expect(ramen_shop.reload.name).to eq 'ラーメン店'
    end

    context 'with invalid params (blank name)' do
      subject(:do_request) { patch ramen_shop_path(ramen_shop), params: { ramen_shop: { name: '' } } }

      it 'returns unprocessable_entity when logged in as an admin' do
        log_in_as admin
        do_request
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it 'does not update the ramen_shop name' do
        original_name = ramen_shop.name
        log_in_as admin
        do_request
        expect(ramen_shop.reload.name).to eq original_name
      end
    end
  end
end
