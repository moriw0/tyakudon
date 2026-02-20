require 'rails_helper'

RSpec.describe 'Records', js: true do
  let(:user) { create(:user, is_test_mode: true) }
  let!(:ramen_shop) { create(:ramen_shop) }

  before do
    log_in_as(user)
    mock_geolocation(50.455755, 30.511565)
  end

  scenario 'user creates a record of the nearby ramen shop' do
    click_link '現在地から接続'

    # searchページ
    expect(page).to_not have_link '現在地から接続'
    expect(page).to have_css '#map', visible: :visible

    # 接続するラーメン店を選択して最初の待ち行列情報を入力
    click_link ramen_shop.name, href: new_ramen_shop_record_path(ramen_shop)
    find('label[for="record_line_statuses_attributes_0_line_type_outside_the_store"]').click
    fill_in '待ち行列数', with: 5
    fill_in 'ひとこと', with: '並ぶぞ'
    click_button '接続する'

    # measureページ
    expect(page).to have_content '接続しました'
    expect(page).to have_content ramen_shop.name
    expect(page).to have_content '00:00:01', wait: 1
    expect(page).to_not have_link '現在地から接続'

    # measureページを一時離脱して再接続
    visit root_path
    record = Record.last
    click_link '接続中レコード', href: measure_record_path(record)
    expect(page).to have_content '再接続しました'
    expect(page).to have_content '00:00:02', wait: 2

    # 待ち行列状況を追加登録
    click_link '追加報告'
    find('label[for="line_status_line_type_outside_the_store"]').click
    fill_in '待ち行列数', with: 1
    ## 着席を選択すると行列数がブランクでhiddenされる
    find('label[for="line_status_line_type_seated"]').click
    expect(find_by_id('line_status_line_number', visible: :hidden).value).to eq ''
    ## 着席以外を選択すると再び数値入力ができるようになる
    find('label[for="line_status_line_type_inside_the_store"]').click
    fill_in '待ち行列数', with: 1
    fill_in 'ひとこと', with: 'もう少し'
    ## 暫定対策: 一呼吸おいてからpost投稿
    sleep(1)
    click_button '報告する'

    # measureページに追加登録情報が反映されている
    expect(page).to have_content '行列の様子を報告しました'
    find('#flush-heading-1 > button').click
    expect(page).to have_content 'もう少し'
    expect(page).to have_content '00:00:05', wait: 3
    click_button 'ちゃくどん'

    # 着丼後の投稿ページ
    expect(page).to have_content 'ちゃくどんレコードを登録しました'
    expect(page).to have_content '00:00:05'
    fill_in 'ひとこと', with: '着丼しました'
    attach_file '写真', Rails.root.join('spec/fixtures/files/1000x800_4.2MB.png'), make_visible: true
    click_button '投稿する'

    # Recordページ
    expect(page).to have_content '投稿しました'
    expect(page).to have_content '00:00:05'
    expect(page).to have_content '着丼しました'
    expect(page).to have_selector("img[src$='1000x800_4.2MB.png']")

    # measureまでブラウザバックするとroot_pathへリダイレクト
    go_back
    go_back
    expect(page).to have_current_path(root_path)
    expect(page).to have_link '現在地から接続'
  end
end
