require 'rails_helper'

RSpec.describe 'Users' do
  before do
    driven_by(:rack_test)
  end

  scenario 'user creates an account with valid information' do
    visit new_user_path
    expect {
      fill_in 'ニックネーム', with: 'もりを'
      fill_in 'メールアドレス', with: 'test@example.com'
      fill_in 'パスワード', with: 'foobar'
      fill_in 'パスワード(確認)', with: 'foobar'
      click_button '登録する'
      expect(page).to have_content '登録が完了しました'
      expect(page).to have_content 'もりを'
    }.to change(User, :count).by(1)
  end
end
