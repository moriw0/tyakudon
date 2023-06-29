require 'rails_helper'

RSpec.describe "Logins", type: :system do
  before do
    driven_by(:rack_test)
  end

  let(:user) { create(:user) }

  scenario 'login with valid email and invalid password' do
    visit login_path
    fill_in 'メールアドレス', with: user.email
    fill_in 'パスワード', with: 'invalid'
    click_button 'ログインする'
    expect(page).to have_content 'ログインに失敗しました'
    visit root_path
    expect(page).not_to have_content 'ログインに失敗しました'
  end

  scenario 'login with valid information' do
    visit login_path
    fill_in 'メールアドレス', with: user.email
    fill_in 'パスワード', with: user.password
    click_button 'ログインする'
    expect(page).to have_content 'ログインしました'
    expect(page).to have_link 'プロフィール', href: user_path(user)
    expect(page).to have_link 'ログアウト', href: logout_path
  end
end
