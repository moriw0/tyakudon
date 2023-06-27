require 'rails_helper'

RSpec.describe "Logins", type: :system do
  before do
    driven_by(:rack_test)
  end

  scenario 'login with invalid information' do
    visit login_path
    fill_in 'メールアドレス', with: 'no-user@example.com'
    fill_in 'パスワード', with: 'foobar'
    click_button 'ログインする'
    expect(page).to have_content 'ログインに失敗しました'
    visit root_path
    expect(page).not_to have_content 'ログインに失敗しました'
  end
end
