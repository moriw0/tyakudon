require 'rails_helper'

RSpec.describe 'NewRecords' do
  describe 'GET /index' do
    it 'returns http success' do
      get new_records_path
      expect(response).to have_http_status(:success)
    end

    context 'with records' do
      let!(:active_records) do
        create_list(:record, 3, :with_line_status, is_retired: false, ramen_shop: create(:ramen_shop, :many_shops))
      end
      let!(:retired_record) do
        create(:record, :with_line_status, is_retired: true, ramen_shop: create(:ramen_shop, :many_shops))
      end

      it 'assigns @records with paginated records' do
        get new_records_path
        expect(controller.instance_variable_get(:@records)).to be_present
      end

      it 'only includes non-retired records' do
        get new_records_path
        assigned = controller.instance_variable_get(:@records)
        expect(assigned).to include(active_records.first)
        expect(assigned).to_not include(retired_record)
      end

      it 'orders by created_at descending' do
        get new_records_path
        assigned = controller.instance_variable_get(:@records)
        expect(assigned.first.created_at).to be >= assigned.last.created_at
      end
    end

    context 'with connecting records' do
      let!(:connecting_record) do
        create(:record_only_has_started_at, :with_line_status, is_retired: false,
                                                               ramen_shop: create(:ramen_shop, :many_shops))
      end
      let!(:finished_record) do
        create(:record, :with_line_status, is_retired: false, ramen_shop: create(:ramen_shop, :many_shops))
      end

      it 'includes connecting records (wait_time is nil)' do
        get new_records_path
        assigned = controller.instance_variable_get(:@records)
        expect(assigned).to include(connecting_record)
      end

      it 'includes both connecting and finished records' do
        get new_records_path
        assigned = controller.instance_variable_get(:@records)
        expect(assigned).to include(connecting_record, finished_record)
      end
    end

    context 'with pagination' do
      before do
        create_list(:record, 30, :with_line_status, ramen_shop: create(:ramen_shop, :many_shops))
      end

      it 'paginates records' do
        get new_records_path, params: { page: 1 }
        assigned = controller.instance_variable_get(:@records)
        expect(assigned).to respond_to(:current_page)
        expect(assigned.current_page).to eq(1)
      end

      it 'respects page parameter' do
        get new_records_path, params: { page: 2 }
        assigned = controller.instance_variable_get(:@records)
        expect(assigned.current_page).to eq(2)
      end
    end
  end
end
