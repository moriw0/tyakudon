require 'rails_helper'

RSpec.describe 'ShopRegisterRequests' do
  let!(:user) { create(:user) }

  before do
    log_in_as user
  end

  describe 'GET /shop_register_request/new' do
    it 'returns http success' do
      get new_shop_register_request_path
      expect(response).to have_http_status(:success)
    end
  end

  describe 'GET /shop_register_request/:id/edit' do
    context 'with admin' do
      let!(:admin) { create(:user, :admin) }

      before { log_in_as admin }

      context 'when open' do
        let!(:shop_request) { create(:shop_register_request, status: 'open', user: user) }

        it 'gets approved' do
          get edit_shop_register_request_path(shop_request)
          expect(shop_request.reload).to be_approved
        end

        it 'redirects to new_ramen_shop_path with params' do
          get edit_shop_register_request_path(shop_request)
          expect(response).to redirect_to new_ramen_shop_path(request: { id: shop_request.id, name: shop_request.name,
                                                                         address: shop_request.address })
        end
      end

      context 'when not open' do
        let!(:shop_request) { create(:shop_register_request, status: 'approved', user: user) }

        it 'redirects to root_path' do
          get edit_shop_register_request_path(shop_request)
          expect(response).to redirect_to root_path
        end

        it 'has a alert flash' do
          get edit_shop_register_request_path(shop_request)
          expect(flash[:alert]).to eq '無効なリンクです'
        end
      end
    end

    context 'with non-admin' do
      let!(:non_admin) { create(:user, admin: false) }
      let!(:shop_request) { create(:shop_register_request, status: 'open', user: user) }

      before { log_in_as non_admin }

      it 'redirects to root_path' do
        get edit_shop_register_request_path(shop_request)
        expect(response).to redirect_to root_path
      end

      it 'has a noticeend flash' do
        get edit_shop_register_request_path(shop_request)
        expect(flash[:notice]).to eq '不正なアクセスです'
      end
    end
  end

  describe 'POST /shop_register_request' do
    context 'when shop does not exist' do
      before { ActionMailer::Base.deliveries.clear }

      let(:do_request) { post shop_register_requests_path, params: shop_register_request_params }

      context 'with valid parameters' do
        let(:shop_register_request_params) { { shop_register_request: attributes_for(:shop_register_request) } }

        it 'creates a new ShopRegisterRequest' do
          expect {
            do_request
          }.to change(ShopRegisterRequest, :count).by(1)
          expect(response).to redirect_to(root_path)
        end

        it 'sends an email' do
          do_request
          expect(ActionMailer::Base.deliveries.size).to eq 1
        end

        it 'redirects to root_path' do
          do_request
          expect(response).to redirect_to root_path
        end

        it 'has a notice flash' do
          do_request
          expect(flash[:notice]).to eq 'リクエストを送信しました'
        end
      end

      context 'with invalid parameters' do
        let(:shop_register_request_params) { { shop_register_request: { name: '', address: '' } } }

        it 'does not create a new ShopRegisterRequest' do
          expect {
            do_request
          }.to_not change(ShopRegisterRequest, :count)
        end

        it 'does not send an email' do
          do_request
          expect(ActionMailer::Base.deliveries.size).to eq 0
        end
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

  describe 'GET /shop_register_request/:id/complete' do
    let!(:ramen_shop) { create(:ramen_shop) }
    let(:do_request) { get complete_shop_register_request_path(shop_request), params: { ramen_shop_id: ramen_shop.id } }

    context 'with admin' do
      let!(:admin) { create(:user, :admin) }

      before { log_in_as admin }

      context 'when approved' do
        let!(:shop_request) { create(:shop_register_request, status: 'approved', user: user) }

        it 'gets completed' do
          do_request
          expect(shop_request.reload).to be_completed
        end

        it 'redirects to root_path' do
          do_request
          expect(response).to redirect_to root_path
        end

        it 'has a notice flash' do
          do_request
          expect(flash[:notice]).to eq '登録完了メールを送信しました'
        end
      end

      context 'when not approved' do
        let!(:shop_request) { create(:shop_register_request, status: 'open', user: user) }

        it 'redirects to root_path' do
          do_request
          expect(response).to redirect_to root_path
        end

        it 'has a alert flash' do
          do_request
          expect(flash[:alert]).to eq '不正なアクセスです'
        end
      end
    end

    context 'with non-admin' do
      let!(:non_admin) { create(:user, admin: false) }
      let!(:shop_request) { create(:shop_register_request, status: 'approved', user: user) }

      before { log_in_as non_admin }

      it 'redirects to root_path' do
        do_request
        expect(response).to redirect_to root_path
      end

      it 'has a noticeend flash' do
        do_request
        expect(flash[:notice]).to eq '不正なアクセスです'
      end
    end
  end
end
