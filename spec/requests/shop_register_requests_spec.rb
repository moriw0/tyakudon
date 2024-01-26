require 'rails_helper'

RSpec.describe 'ShopRegisterRequests' do
  let!(:non_admin) { create(:user, admin: false) }

  shared_examples 'when not logged in' do
    it 'redirects to login_path' do
      do_request
      expect(response).to redirect_to login_path
    end
  end

  shared_examples 'as a non-admin' do
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

  describe 'GET /shop_register_request/new' do
    let(:do_request) { get new_shop_register_request_path }

    it_behaves_like 'when not logged in'

    context 'when logged in' do
      before { log_in_as non_admin }

      it 'returns http success' do
        do_request
        expect(response).to have_http_status(:success)
      end
    end
  end

  describe 'GET /shop_register_request/:id/edit' do
    let!(:shop_request) { create(:shop_register_request, status: 'open', user: non_admin) }
    let(:do_request) { get edit_shop_register_request_path(shop_request) }

    it_behaves_like 'when not logged in'
    it_behaves_like 'as a non-admin'

    context 'with admin' do
      let!(:admin) { create(:user, :admin) }

      before { log_in_as admin }

      context 'when status is open' do
        let!(:shop_request) { create(:shop_register_request, status: 'open', user: non_admin) }
        let(:do_request) { get edit_shop_register_request_path(shop_request) }

        it 'makes status approved' do
          do_request
          expect(shop_request.reload).to be_approved
        end

        it 'redirects to new_ramen_shop_path with params' do
          do_request
          expect(response).to redirect_to new_ramen_shop_path(request: { id: shop_request.id, name: shop_request.name,
                                                                         address: shop_request.address })
        end
      end

      context 'when status is not open' do
        let!(:shop_request) { create(:shop_register_request, status: 'approved', user: non_admin) }
        let(:do_request) { get edit_shop_register_request_path(shop_request) }

        it 'redirects to root_path' do
          do_request
          expect(response).to redirect_to root_path
        end

        it 'has a alert flash' do
          do_request
          expect(flash[:alert]).to eq '無効なリンクです'
        end
      end
    end
  end

  describe 'POST /shop_register_request' do
    let!(:shop_register_request_params) { { shop_register_request: attributes_for(:shop_register_request) } }
    let(:do_request) { post shop_register_requests_path, params: shop_register_request_params }

    it_behaves_like 'when not logged in'

    context ['when logged in', 'shop does not exist'].join(', ') do
      before do
        log_in_as non_admin
        ActionMailer::Base.deliveries.clear
      end

      context 'with valid parameters' do
        let!(:shop_register_request_params) { { shop_register_request: attributes_for(:shop_register_request) } }
        let(:do_request) { post shop_register_requests_path, params: shop_register_request_params }

        before { allow(ENV).to receive(:fetch).with('ADMIN_EMAIL').and_return('admin@example.com') }

        it 'creates a new ShopRegisterRequest' do
          expect {
            do_request
          }.to change(ShopRegisterRequest, :count).by(1)
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
        let!(:shop_register_request_params) { { shop_register_request: { name: '', address: '' } } }
        let(:do_request) { post shop_register_requests_path, params: shop_register_request_params }

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

    context ['when logged in', 'shop already exists'].join(', ') do
      let(:do_request) do
        post shop_register_requests_path, params: { shop_register_request: { name: 'よくある店舗', address: '東京都新宿区' } }
      end

      before do
        log_in_as non_admin
        create(:ramen_shop, name: 'よくある店舗', address: '東京都新宿区')
      end

      it 'does not create a new ShopRegisterRequest' do
        do_request
        expect(ShopRegisterRequest.count).to eq(0)
      end

      it 'has a alert flash' do
        do_request
        expect(flash[:alert]).to eq '店舗が既に存在します。'
      end
    end
  end

  describe 'GET /shop_register_request/:id/complete' do
    let!(:ramen_shop) { create(:ramen_shop) }
    let!(:shop_request) { create(:shop_register_request, status: 'approved', user: non_admin) }
    let(:do_request) do
      get complete_shop_register_request_path(shop_request), params: { ramen_shop_id: ramen_shop.id }
    end

    it_behaves_like 'when not logged in'
    it_behaves_like 'as a non-admin'

    context 'with admin' do
      let!(:admin) { create(:user, :admin) }

      before { log_in_as admin }

      context 'when status is approved' do
        let!(:shop_request) { create(:shop_register_request, status: 'approved', user: non_admin) }
        let(:do_request) do
          get complete_shop_register_request_path(shop_request), params: { ramen_shop_id: ramen_shop.id }
        end

        it 'makes status completed' do
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

      context 'when status is not approved' do
        let!(:shop_request) { create(:shop_register_request, status: 'open', user: non_admin) }
        let(:do_request) do
          get complete_shop_register_request_path(shop_request), params: { ramen_shop_id: ramen_shop.id }
        end

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
  end
end
