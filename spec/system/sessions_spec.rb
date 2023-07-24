require 'rails_helper'

RSpec.describe 'Logins' do
  let(:user) { create(:user) }

  scenario 'login with valid email and invalid password' do
    visit login_path
    fill_in 'メールアドレス', with: user.email
    fill_in 'パスワード', with: 'invalid'
    click_button 'ログインする'
    expect(page).to have_content 'ログインに失敗しました'
    visit root_path
    expect(page).to_not have_content 'ログインに失敗しました'
  end

  scenario 'login with valid information followed by logout' do
    visit login_path
    fill_in 'メールアドレス', with: user.email
    fill_in 'パスワード', with: user.password
    click_button 'ログインする'
    expect(page).to have_content 'ログインしました'
    expect(page).to have_link 'プロフィール', href: user_path(user)
    expect(page).to have_link 'ログアウト', href: logout_path
    click_link 'ログアウト'
    expect(page).to have_content 'ログアウトしました'
    expect(page).to have_link 'ログイン', href: login_path
    expect(page).to_not have_link 'ログアウト', href: logout_path
  end
end
