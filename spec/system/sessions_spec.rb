require 'rails_helper'

RSpec.describe 'Logins' do
  let(:user) { create(:user) }

  before { enable_v2_ui }

  it 'login with valid email and invalid password' do
    visit login_path
    fill_in 'メールアドレス', with: user.email
    fill_in 'パスワード', with: 'invalid'
    click_button 'ログインする'
    expect(page).to have_content 'ログインに失敗しました'
    visit root_path
    expect(page).to_not have_content 'ログインに失敗しました'
  end

  it 'login with valid information followed by logout', :js do
    visit login_path
    fill_in 'メールアドレス', with: user.email
    fill_in 'パスワード', with: user.password
    click_button 'ログインする'
    expect(page).to have_content 'ログインしました'
    expect(page).to have_link user.name, href: user_path(user)
    click_link user.name
    expect(page).to have_link 'ログアウトする', href: logout_path
    accept_confirm { click_link 'ログアウトする' }
    expect(page).to have_content 'ログアウトしました'
    expect(page).to have_link 'ログイン', href: login_path
    expect(page).to_not have_link user.name, href: user_path(user)
  end
end
