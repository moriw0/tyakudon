require 'rails_helper'

RSpec.describe 'V2 UI feature flag' do
  let(:user) { create(:user) }
  let(:ramen_shop) { create(:ramen_shop) }
  let(:record) { create(:record_only_has_started_at, ramen_shop: ramen_shop, user: user) }

  describe 'handle_v2_flag (via before_action on ApplicationController)' do
    context 'when ?v2=1 is passed' do
      it 'sets v2_ui cookie' do
        get root_path, params: { v2: '1' } # rubocop:disable Naming/VariableNumber
        expect(cookies[:v2_ui]).to eq('1')
      end
    end

    context 'when ?v2=0 is passed' do
      it 'deletes v2_ui cookie' do
        cookies[:v2_ui] = '1'
        get root_path, params: { v2: '0' } # rubocop:disable Naming/VariableNumber
        expect(cookies[:v2_ui]).to be_blank
      end
    end

    context 'when no v2 param is passed' do
      it 'does not modify the cookie' do
        cookies[:v2_ui] = '1'
        get root_path
        expect(cookies[:v2_ui]).to eq('1')
      end
    end
  end

  describe 'resolve_layout' do
    context 'when v2_ui cookie is absent' do
      it 'uses the default application layout' do
        log_in_as(user)
        get measure_record_path(record)
        expect(response.body).to_not include('stylesheet_v2')
        # v2 layout loads v2.css; default layout loads application.css
        expect(response.body).to_not match(/<link[^>]*v2\.css/)
      end
    end

    context 'when v2_ui cookie is present but use_v2_layout! was not called (no opt-in)' do
      it 'uses the default application layout' do
        cookies[:v2_ui] = '1'
        # Use a controller that has NOT opted in to v2 layout.
        # FaqsController is intentionally kept as v1-only for this assertion.
        # If you migrate faqs to v2, update this to another non-v2 route.
        get faqs_path
        expect(response.body).to_not match(/<link[^>]*v2\.css/)
      end
    end

    context 'when v2_ui cookie is present and use_v2_layout! was called' do
      it 'uses the v2 layout' do
        log_in_as(user)
        cookies[:v2_ui] = '1'
        get measure_record_path(record)
        # v2 layout loads v2.css (fingerprinted); default layout loads application.css
        expect(response.body).to match(%r{href="/assets/v2[^"]*\.css})
      end
    end
  end

  describe 'use_v2_layout! (Records#measure)' do
    context 'when v2_ui cookie is absent' do
      it 'renders the v1 measure template' do
        log_in_as(user)
        get measure_record_path(record)
        # v1 template uses Bootstrap with shop-name/cheer_messages; v2 uses a plain table
        expect(response.body).to include('class="shop-name"')
        expect(response.body).to include('id="cheer_messages"')
      end
    end

    context 'when v2_ui cookie is present' do
      it 'renders the v2 variant of the measure template' do
        log_in_as(user)
        cookies[:v2_ui] = '1'
        get measure_record_path(record)
        # v2 template uses a plain table with col-th headers; no shop-name or cheer_messages
        expect(response.body).to include('class="col-th"')
        expect(response.body).to_not include('class="shop-name"')
      end
    end
  end
end
