require 'rails_helper'

RSpec.describe ApplicationHelper do
  describe '#toggle_ui_path' do
    before do
      allow(helper.request).to receive_messages(path: '/ramen_shops', query_parameters: {})
    end

    it 'v2=1 を付与したパスを返す' do
      expect(helper.toggle_ui_path(enable_v2: true)).to eq('/ramen_shops?v2=1') # rubocop:disable Naming/VariableNumber
    end

    it 'v2=0 を付与したパスを返す' do
      expect(helper.toggle_ui_path(enable_v2: false)).to eq('/ramen_shops?v2=0') # rubocop:disable Naming/VariableNumber
    end

    context 'when existing query parameters are present' do
      before do
        allow(helper.request).to receive_messages(
          path: '/ramen_shops',
          query_parameters: { 'q' => 'ラーメン', 'v2' => '1' }
        )
      end

      it '既存パラメータを保持しつつ v2 を上書きする' do
        result = helper.toggle_ui_path(enable_v2: false) # rubocop:disable Naming/VariableNumber
        expect(result).to include('v2=0')
        expect(result).to include('q=')
        expect(result).to_not include('v2=1')
      end
    end
  end
end
