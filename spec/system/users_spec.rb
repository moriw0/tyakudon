require 'rails_helper'

RSpec.describe 'Users' do
  let(:user) { create(:user) }

  scenario 'user creates an account with valid information' do
    visit new_user_path
    expect {
      fill_in 'ニックネーム', with: 'もりを'
      fill_in 'メールアドレス', with: 'test@example.com'
      fill_in 'パスワード', with: 'foobar'
      fill_in 'パスワード(確認)', with: 'foobar'
      click_button '登録する'
      expect(page).to have_content 'メールを確認してアカウントを有効にしてください'
    }.to change(User, :count).by(1)
  end

  scenario 'user update the account with valid information' do
    log_in_as(user)
    visit edit_user_path(user)
    expect {
      fill_in 'ニックネーム', with: 'Foo bar'
      fill_in 'メールアドレス', with: 'foo@bar.com'
      fill_in 'パスワード', with: ''
      fill_in 'パスワード(確認)', with: ''
      attach_file 'アバター', Rails.root.join('spec/fixtures/files/1000x800_4.2MB.png'), make_visible: true
      click_button '更新する'
      expect(page).to have_content 'ユーザー情報を更新しました'
      expect(page).to have_content 'Foo bar'
      expect(page).to have_selector("img[src$='1000x800_4.2MB.png'].avatar")
    }.to_not change(User, :count)
  end

  scenario 'user cannot update the account with invalid information' do
    log_in_as(user)
    visit edit_user_path(user)
    expect {
      fill_in 'ニックネーム', with: ''
      fill_in 'メールアドレス', with: 'foo@invalid'
      fill_in 'パスワード', with: 'foo'
      fill_in 'パスワード(確認)', with: 'bar'
      attach_file 'アバター', Rails.root.join('spec/fixtures/files/1000x800_5.3MB.png'), make_visible: true
      click_button '更新する'
      expect(page).to have_content '入力してください'
      expect(page).to have_content '不正な値です'
      expect(page).to have_content '6文字以上で入力してください'
      expect(page).to have_content 'パスワードの入力が一致しません'
      expect(page).to have_content '5MB以下である必要があります'
    }.to_not change(User, :count)
  end

  describe 'index' do
    let!(:admin) { create(:user) }
    let!(:non_admin) { create(:other_user) }

    before do
      create_list(:all_user, 15)
    end

    context 'with admin' do
      it 'shows users including pagination and delete link' do
        log_in_as(admin)
        visit users_path
        expect(page).to have_selector('.pagination')
        first_page_of_users = User.page(1)
        first_page_of_users.each do |user|
          expect(page).to have_link user.name, href: user_path(user)
          expect(page).to have_link '削除', href: user_path(user) unless user == admin
        end
        expect {
          click_link '削除', href: user_path(non_admin)
        }.to change(User, :count).by(-1)
      end
    end

    context 'with non-admin' do
      it 'shows users not including delete link' do
        log_in_as(non_admin)
        visit users_path
        expect(page).to_not have_link '削除'
      end

      it 'does not show non_activated_user' do
        non_activated_user = create(:non_activated_user)
        log_in_as(non_admin)
        visit users_path
        expect(page).to_not have_link non_activated_user.name, href: user_path(non_activated_user)
        click_link href: '/users?page=2', match: :first
        expect(page).to_not have_link non_activated_user.name, href: user_path(non_activated_user)
      end
    end
  end

  describe 'show' do
    include ApplicationHelper

    let(:user) { create(:user) }
    let(:other_user) { create(:other_user) }
    let(:ramen_shop) { create(:ramen_shop) }

    it 'shows edit_user_path when vist current_user path' do
      log_in_as(user)
      visit user_path(other_user)
      expect(page).to_not have_link 'ユーザー情報を編集する', href: edit_user_path(other_user)
      visit user_path(user)
      expect(page).to have_link 'ユーザー情報を編集する', href: edit_user_path(user)
    end

    it 'shows their profile and records' do
      create_list(:many_records, 15, user: user, ramen_shop: ramen_shop)
      create(:record, user: user, is_retired: true, ramen_shop: ramen_shop)

      visit user_path(user)
      expect(find('h1')).to have_content user.name
      expect(find('h1>img.avatar')).to be_truthy
      expect(find('h6>span')).to have_content user.records.count
      expect(find('ul.pagination')).to be_truthy

      user.records.page(1).each do |record|
        expect(page).to have_content format_datetime(record.created_at)
        expect(page).to have_content format_wait_time(record.wait_time)

        if record.is_retired?
          expect(page).to have_content 'リタイア'
        else
          expect(page).to have_content 'ちゃくどん'
        end
      end
    end
  end
end
