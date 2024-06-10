require 'rails_helper'
RSpec.describe '/faqs' do
  shared_examples 'when not logged in' do
    it 'redirects to login_path' do
      do_request
      expect(response).to redirect_to login_path
    end
  end

  shared_examples 'as a non-admin' do
    let!(:non_admin) { create(:user, :other_user) }

    it 'redirects to root_path' do
      log_in_as non_admin
      do_request
      expect(response).to redirect_to root_path
    end
  end

  describe 'GET /index' do
    it 'renders a successful response' do
      get faqs_url
      expect(response).to be_successful
    end
  end

  describe 'GET /show' do
    let!(:faq) { create(:faq) }

    it 'renders a successful response' do
      get faq_url(faq)
      expect(response).to be_successful
    end
  end

  describe 'GET /new' do
    subject(:do_request) { get new_faq_path }

    let!(:admin) { create(:user, :admin) }

    it_behaves_like 'when not logged in'
    it_behaves_like 'as a non-admin'

    context 'with admin' do
      before { log_in_as admin }

      it 'renders a successful response' do
        do_request
        expect(response).to be_successful
      end
    end
  end

  describe 'GET /edit' do
    subject(:do_request) { get edit_faq_path(faq) }

    let!(:faq) { create(:faq) }
    let!(:admin) { create(:user, :admin) }

    it_behaves_like 'when not logged in'
    it_behaves_like 'as a non-admin'

    context 'with admin' do
      before { log_in_as admin }

      it 'renders a successful response' do
        do_request
        expect(response).to be_successful
      end
    end
  end

  describe 'POST /create' do
    subject(:do_request) { post faqs_path, params: valid_attributes }

    let!(:admin) { create(:user, :admin) }
    let!(:valid_attributes) do
      { faq: {
        question: 'どんなアプリ？',
        answer: 'ラーメン待ち時間共有アプリです。'
      } }
    end

    it_behaves_like 'when not logged in'
    it_behaves_like 'as a non-admin'

    context 'with admin' do
      before { log_in_as admin }

      context 'with valid parameters' do
        it 'creates a new Faq' do
          expect {
            do_request
          }.to change(Faq, :count).by(1)
        end

        it 'redirects to the created faq' do
          do_request
          expect(response).to redirect_to faq_path(Faq.last)
        end
      end

      context 'with invalid parameters' do
        subject(:do_request) do
          post faqs_path, params: { faq: {
            question: '',
            answer: ''
          } }
        end

        it 'does not create a new Faq' do
          expect {
            do_request
          }.to_not change(Faq, :count)
        end

        it "renders a response with 422 status (i.e. to display the 'new' template)" do
          do_request
          expect(response).to have_http_status(:unprocessable_entity)
        end
      end
    end
  end

  describe 'PATCH /update' do
    subject(:do_request) { patch faq_path(faq), params: valid_attributes }

    let!(:faq) { create(:faq) }
    let!(:admin) { create(:user, :admin) }
    let!(:valid_attributes) do
      { faq: {
        question: 'どんなアプリ？',
        answer: '素敵なアプリです'
      } }
    end

    it_behaves_like 'when not logged in'
    it_behaves_like 'as a non-admin'

    context 'with admin' do
      before { log_in_as admin }

      context 'with valid parameters' do
        it 'updates the requested faq' do
          do_request
          expect(faq.reload.answer).to eq '素敵なアプリです'
        end

        it 'redirects to the faq' do
          do_request
          expect(response).to redirect_to faq_path(faq)
        end
      end

      context 'with invalid parameters' do
        subject(:do_request) do
          patch faq_path(faq), params: { faq: {
            question: '',
            answer: ''
          } }
        end

        it "renders a response with 422 status (i.e. to display the 'edit' template)" do
          do_request
          expect(response).to have_http_status(:unprocessable_entity)
        end
      end
    end
  end

  describe 'DELETE /destroy' do
    subject(:do_request) { delete faq_path(faq) }

    let!(:faq) { create(:faq) }
    let!(:admin) { create(:user, :admin) }

    it_behaves_like 'when not logged in'
    it_behaves_like 'as a non-admin'

    context 'with admin' do
      before { log_in_as admin }

      it 'destroys the requested faq' do
        expect {
          do_request
        }.to change(Faq, :count).by(-1)
      end

      it 'redirects to the faqs list' do
        do_request
        expect(response).to redirect_to faqs_path
      end
    end
  end
end
