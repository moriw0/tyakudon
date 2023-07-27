require 'rails_helper'

RSpec.describe 'Records', js: true do
  let(:user) { create(:user) }
  let!(:ramen_shop) { create(:ramen_shop) }

  before do
    log_in_as(user)
  end

  scenario 'user creates a record of the nearby ramen shop' do
    click_link '現在地からセツゾク'

    # searchページ
    expect(page).to_not have_link '現在地からセツゾク'
    expect(page).to have_css '.loading-spinner'
    expect(page).to have_css '#map', visible: :visible, wait: 15
    expect(page).to_not have_css '.loading-spinner'

    # 接続するラーメン店を選択して最初の待ち行列情報を入力
    click_link ramen_shop.name, href: new_ramen_shop_record_path(ramen_shop)
    fill_in '待ち行列数', with: 5
    choose '店内'
    fill_in 'ひとこと', with: '並ぶぞ'
    click_button '登録する'

    # measureページ
    expect(page).to have_content 'セツゾクしました'
    expect(page).to have_content ramen_shop.name
    expect(page).to have_content '00:00:01', wait: 1
    expect(page).to_not have_link '現在地からセツゾク'

    # measureページを一時離脱して再接続
    visit root_path
    record = Record.last
    click_link '接続中レコード', href: measure_record_path(record)
    expect(page).to have_content '再セツゾクしました'
    expect(page).to have_content '00:00:03', wait: 3

    # 待ち行列状況を追加登録
    click_link '追加登録'
    fill_in '待ち行列数', with: 1
    choose '店内'
    fill_in 'ひとこと', with: 'もう少し'
    click_button '登録する'
    sleep(1) # 暫定対策: responseを待ってからmodalを強制的に閉じる
    find('button[data-bs-dismiss="modal"]').click

    # measureページに追加登録情報が反映されている
    expect(page).to have_content '行列の様子を登録しました'
    expect(page).to have_content 'もう少し'
    expect(page).to have_content '00:00:05', wait: 2
    click_button 'ちゃくどん'

    # 着丼後の投稿ページ
    expect(page).to have_content 'ちゃくどんレコードを登録しました'
    expect(page).to have_content '00:00:05'
    fill_in '着丼してひとこと', with: '着丼しました'
    click_button '投稿する'

    # Recordページ
    expect(page).to have_content '投稿しました'
    expect(page).to have_content '00:00:05'
    expect(page).to have_content '着丼しました'

    # measureまでブラウザバックするとroot_pathへリダイレクト
    go_back
    go_back
    expect(page).to have_current_path(root_path)
    expect(page).to have_link '現在地からセツゾク'
  end
end
