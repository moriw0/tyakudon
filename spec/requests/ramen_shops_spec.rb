require 'rails_helper'

RSpec.describe "RamenShops", type: :request do
  let(:ramen_shop) { create(:ramen_shop) }
  let(:non_admin) { create(:other_user) }
  let(:admin) { create(:user) }


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

  describe "GET /ramen_shops/new #new" do
    let(:do_request) { get new_ramen_shop_path }

    it_behaves_like 'when not logged in'
    it_behaves_like 'as a non-admin'

    it 'returns new form when logged in as an admin' do
      log_in_as admin
      do_request
      expect(response.body).to include '<h1>店舗登録</h1>'
    end
  end

  describe "GET /ramen_shops/:id/edit #edit" do
    let(:do_request) { get edit_ramen_shop_path(ramen_shop) }

    it_behaves_like 'when not logged in'
    it_behaves_like 'as a non-admin'

    it 'returns edit form when logged in as an admin' do
      log_in_as admin
      do_request
      expect(response.body).to include '<h1>店舗更新</h1>'
    end
  end

  describe "POST /ramen_shops #create" do
    let(:do_request) { post ramen_shops_path, params: ramen_shop_params }
    let(:ramen_shop_params) { { ramen_shop: attributes_for(:ramen_shop) } }

    it_behaves_like 'when not logged in'
    it_behaves_like 'as a non-admin'

    it 'creates ramen_shop when logged in as an admin' do
      log_in_as admin
      expect {
        do_request
      }.to change(RamenShop, :count).by(1)
    end
  end

  describe "PATCH /ramen_shops/:id #update" do
    let(:do_request) { patch ramen_shop_path(ramen_shop), params: ramen_shop_params }
    let(:ramen_shop_params) { { ramen_shop: attributes_for(:ramen_shop, name: 'ラーメン店') } }

    it_behaves_like 'when not logged in'
    it_behaves_like 'as a non-admin'

    it 'updates ramen_shop when logged in as an admin' do
      log_in_as admin
      do_request
      expect(ramen_shop.reload.name).to eq 'ラーメン店'
    end
  end
end
