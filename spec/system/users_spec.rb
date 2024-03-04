require 'rails_helper'

RSpec.describe 'Users' do
  describe '#create' do
    context 'when standard creation' do
      before { create(:record) }

      scenario 'user creates an account with valid information', js: true do
        visit new_user_path
        expect {
          fill_in 'ニックネーム', with: 'もりを'
          fill_in 'メールアドレス', with: 'test@example.com'
          fill_in 'パスワード', with: 'foobar'
          fill_in 'パスワード（確認）', with: 'foobar'
          find('input#agreement').click
          click_button '登録する'
          expect(page).to have_content 'メールを確認してアカウントを有効にしてください'
        }.to change(User, :count).by(1)
      end
    end

    context 'when OAuth creation' do
      before do
        Rails.application.env_config['omniauth.auth'] = set_omniauth
      end

      after do
        Rails.application.env_config.delete('omniauth.auth')
      end

      context 'with valid information' do
        scenario 'user creates an account and logins', js: true do
          visit new_user_path
          click_button 'Googleアカウントでログインする'

          expect(page).to have_selector("input[type='email'][disabled][value='oauth@example.com']")
          expect(page).to have_field('ニックネーム', with: '')

          expect {
            fill_in 'ニックネーム', with: 'もりを'
            find('input#agreement').click
            click_button '登録する'
            expect(page).to have_content 'ログインしました'
          }.to change(User, :count).by(1)

          expect(User.last.email).to eq 'oauth@example.com'
          find('label.open').click
          click_link 'プロフィール'
          expect(page).to have_content 'もりを'
        end
      end

      context 'with invalid information' do
        scenario 'user does not create an account', js: true do
          visit new_user_path
          click_button 'Googleアカウントでログインする'

          expect {
            fill_in 'ニックネーム', with: ' '
            find('input#agreement').click
            click_button '登録する'
          }.to_not change(User, :count)

          expect(page).to have_content 'ニックネームを入力してください。'
          expect(page).to have_selector("input[type='email'][disabled][value='oauth@example.com']")
        end
      end
    end
  end

  describe '#update' do
    let!(:user) { create(:user) }

    scenario 'user update the account with valid information' do
      log_in_as(user)
      visit edit_user_path(user)
      expect {
        fill_in 'ニックネーム', with: 'Foo bar'
        attach_file 'アバター', Rails.root.join('spec/fixtures/files/1000x800_8.4MB.png'), make_visible: true
        click_button '更新する'
        expect(page).to have_content 'ユーザー情報を更新しました'
        expect(page).to have_content 'Foo bar'
        expect(page).to have_selector("img[src$='1000x800_8.4MB.png'].avatar")
      }.to_not change(User, :count)
    end

    scenario 'user cannot update the account with invalid information' do
      log_in_as(user)
      visit edit_user_path(user)
      expect {
        fill_in 'ニックネーム', with: ''
        attach_file 'アバター', Rails.root.join('spec/fixtures/files/1000x800_9.5MB.png'), make_visible: true
        click_button '更新する'
        expect(page).to have_content '入力してください'
        expect(page).to have_content 'アバターのファイルサイズは9MB以下にしてください。'
      }.to_not change(User, :count)
    end

    scenario 'user receives an alert when trying to upload a file larger than 9MB', js: true do
      log_in_as(user)
      visit edit_user_path(user)
      attach_file 'アバター', Rails.root.join('spec/fixtures/files/1000x800_9.5MB.png')
      expect(page.driver.browser.switch_to.alert.text).to eq '最大9MBまでアップロード可能です'
    end
  end

  describe '#index' do
    context 'with 15 users' do
      let!(:admin) { create(:user, admin: true) }

      before { create_list(:user, 15, :many_user) }

      context 'when logged in as admin' do
        before { log_in_as(admin) }

        it 'shows users including pagination' do
          visit users_path
          expect(page).to have_selector('.pagination')
        end
      end

      context 'when logged in as non admin' do
        let!(:non_admin) { create(:user, :other_user, admin: false) }

        before { log_in_as(non_admin) }

        it 'blocks access to users page and shows unauthorized access message' do
          visit users_path
          expect(page).to have_content '不正なアクセスです'
        end
      end
    end

    context ['when logged in as admin', 'with some users'].join(', ') do
      let!(:admin) { create(:user, admin: true) }

      before do
        create_list(:user, 3, :many_user)
        log_in_as(admin)
      end

      context 'with non admin user' do
        let!(:non_admin) { create(:user, :other_user, admin: false) }
        let!(:users) { User.all }

        scenario ['admin can see users', 'delete non admin user'].join(', ') do
          visit users_path

          users.each do |user|
            within "#user_#{user.id}" do
              expect(page).to have_link user.name, href: user_path(user)
              expect(page).to have_link '削除', href: user_path(user) unless user == admin
            end
          end
          expect {
            click_link '削除', href: user_path(non_admin)
          }.to change(User, :count).by(-1)
        end
      end

      context 'with not activated user' do
        let!(:not_activated_user) { create(:user, :not_activated) }
        let!(:users) { User.all }

        scenario 'admin can see not an activated user with tag' do
          visit users_path

          users.each do |user|
            within "#user_#{user.id}" do
              if user.activated
                expect(page).to_not have_content '未有効化'
                expect(page).to have_content user.name
              else
                expect(page).to have_content '未有効化'
                expect(page).to have_content not_activated_user.name
              end
            end
          end
        end
      end
    end
  end

  describe '#show' do
    include ApplicationHelper
    let!(:user) { create(:user) }

    context 'when vist current user path' do
      let!(:other_user) { create(:user, :other_user) }

      before { log_in_as(user) }

      it 'shows edit_user_path' do
        visit user_path(other_user)
        expect(page).to_not have_link 'プロフィールを編集する', href: edit_user_path(other_user)
        visit user_path(user)
        expect(page).to have_link 'プロフィールを編集する', href: edit_user_path(user)
      end
    end

    context 'when visit standerd user path' do
      let!(:ramen_shop) { create(:ramen_shop) }

      it 'shows their profile and records' do
        create_list(:record, 15, :many_records, user: user, ramen_shop: ramen_shop, skip_validation: true)
        create(:record, user: user, is_retired: true, ramen_shop: ramen_shop)

        Record.all.each do |record|
          create(:line_status, record: record)
        end

        visit user_path(user)
        expect(find('h1')).to have_content user.name
        expect(find('img.avatar')).to be_truthy
        expect(find('.stats a')).to have_content user.records.count
        expect(find('ul.pagination')).to be_truthy

        user.records.active_ordered.page(1).each do |record|
          expect(page).to have_content format_datetime(record.started_at)
          expect(page).to have_content format_wait_time_helper(record.wait_time)

          if record.is_retired?
            expect(page).to have_content 'リタイア'
          else
            expect(page).to have_content 'ちゃくどん'
          end
        end
      end
    end
  end
end
