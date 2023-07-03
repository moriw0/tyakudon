require 'rails_helper'

RSpec.describe 'Users' do
  before do
    driven_by(:rack_test)
  end

  let(:user) { create(:user) }

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

  scenario 'user cannot update the account with invalid information' do
    log_in_as(user)
    visit edit_user_path(user)
    expect {
      fill_in 'ニックネーム', with: 'Foo bar'
      fill_in 'メールアドレス', with: 'foo@bar.com'
      fill_in 'パスワード', with: ''
      fill_in 'パスワード(確認)', with: ''
      click_button '更新する'
      expect(page).to have_content 'ユーザー情報を更新しました'
      expect(page).to have_content 'Foo bar'
    }.to_not change(User, :count)
  end

  scenario 'user update the account with valid information' do
    log_in_as(user)
    visit edit_user_path(user)
    expect {
      fill_in 'ニックネーム', with: ''
      fill_in 'メールアドレス', with: 'foo@invalid'
      fill_in 'パスワード', with: 'foo'
      fill_in 'パスワード(確認)', with: 'bar'
      click_button '更新する'
      expect(page).to have_content '入力してください'
      expect(page).to have_content '不正な値です'
      expect(page).to have_content '6文字以上で入力してください'
      expect(page).to have_content 'Passwordの入力が一致しません'
    }.to_not change(User, :count)
  end

  describe 'index' do
    before do
      30.times do
        create(:all_user)
      end
    end

    it 'shows users including pagination' do
      log_in_as(user)
      visit users_path
      expect(page).to have_selector('.pagination')
      User.page(1).each do |user|
        expect(page).to have_link user.name, href: user_path(user)
      end
    end
  end
end
