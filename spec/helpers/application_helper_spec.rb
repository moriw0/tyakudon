require 'rails_helper'

RSpec.describe ApplicationHelper do
  describe '#toggle_ui_path' do
    before do
      allow(helper.request).to receive_messages(path: '/ramen_shops', query_parameters: {})
    end

    it 'v2=1 を付与したパスを返す' do
      expect(helper.toggle_ui_path(enable_v2: true)).to eq('/ramen_shops?v2=1')
    end

    it 'v2=0 を付与したパスを返す' do
      expect(helper.toggle_ui_path(enable_v2: false)).to eq('/ramen_shops?v2=0')
    end

    context '既存クエリパラメータがある場合' do
      before do
        allow(helper.request).to receive_messages(
          path: '/ramen_shops',
          query_parameters: { 'q' => 'ラーメン', 'v2' => '1' }
        )
      end

      it '既存パラメータを保持しつつ v2 を上書きする' do
        result = helper.toggle_ui_path(enable_v2: false)
        expect(result).to include('v2=0')
        expect(result).to include('q=')
        expect(result).not_to include('v2=1')
      end
    end
  end
end
