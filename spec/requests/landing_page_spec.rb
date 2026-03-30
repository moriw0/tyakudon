require 'rails_helper'

RSpec.describe 'LandingPages' do
  describe 'GET /lp' do
    before { create(:record) }

    it 'returns http success' do
      get lp_path
      expect(response).to have_http_status(:success)
    end

    context 'with v2_ui cookie' do
      before do
        create_list(:faq, 3)
        cookies[:v2_ui] = '1'
      end

      it 'uses the v2 layout' do
        get lp_path
        expect(response.body).to match(%r{href="/assets/v2[^"]*\.css})
      end

      it 'renders the records table partial' do
        get lp_path
        expect(response.body).to include('table')
      end

      it 'renders the faqs section' do
        get lp_path
        expect(response.body).to include('よくある質問')
      end

      it 'assigns @new_records' do
        get lp_path
        expect(controller.instance_variable_get(:@new_records)).to be_present
      end

      it 'assigns @faqs limited to 3' do
        create_list(:faq, 5)
        get lp_path
        expect(controller.instance_variable_get(:@faqs).size).to eq(3)
      end
    end

    context 'without v2_ui cookie' do
      it 'uses the lp layout' do
        get lp_path
        expect(response.body).to_not match(%r{href="/assets/v2[^"]*\.css})
      end
    end
  end
end
