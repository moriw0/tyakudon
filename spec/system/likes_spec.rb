require 'rails_helper'

RSpec.describe 'Likes', js: true do
  let!(:ramen_shop) { create(:ramen_shop) }
  let!(:user) { create(:user) }
  let!(:users) { build_stubbed_list(:user, 5, :many_user) }
  let!(:records) { build_stubbed_list(:record, 5, :many_records, ramen_shop: ramen_shop, user: user) }
  let!(:line_statuses) { records.map { |record| build_stubbed(:line_status, record: record) } }
  let!(:likes) do
    records.each_with_index.map { |record, i|
      users.first(i).map do |user|
        build_stubbed(:like, record: record, user: user)
      end
    }.flatten
  end

  # rubocop:disable Rails/SkipsModelValidations
  before do
    User.insert_all users.map(&:attributes)
    Record.insert_all records.map(&:attributes)
    LineStatus.insert_all line_statuses.map(&:attributes)
    Like.insert_all likes.map(&:attributes)
  end
  # rubocop:enable Rails/SkipsModelValidations

  context 'with all user' do
    scenario 'user can see a record-feed order by most likes with hihlights' do
      visit root_path

      # タブとソートタイプがハイライトされていることを確認
      expect(page).to have_selector 'a.selected-tab', text: 'ランキング'
      expect(page).to have_selector 'a.selected-type', text: 'おそい'
      click_link 'いいね'
      expect(page).to have_selector 'a.selected-type', text: 'おそい'
      expect(page).to have_selector 'a.selected-type', text: 'いいね'

      # いいね数順にソートされていることを確認
      like_counts = all('.like-count').map { |like| like.text.to_i }
      expect(like_counts[0]).to eq 4
      expect(like_counts[1]).to eq 3
      expect(like_counts[2]).to eq 2
      expect(like_counts[3]).to eq 1
      expect(like_counts[4]).to eq 0
    end

    scenario 'user redirects to login_path when click like button' do
      visit ranking_path(sort: 'most_likes')
      all('.like-button').first.click
      expect(page).to have_content 'ログインしてください'
    end
  end

  context 'with login other users' do
    before { log_in_as(user) }

    scenario 'user adds and removes a like in both feed page and the record page' do
      # フィードページ
      visit ranking_path(sort: 'most_likes')
      top_record_id = Record.order_by_most_likes.first.id

      founded_like_button = find("#record_#{top_record_id}")
      expect(founded_like_button).to_not have_selector '.like-button.clicked'
      expect(founded_like_button.find('.like-count').text.to_i).to eq 4

      founded_like_button.click
      founded_like_button = find("#record_#{top_record_id}")
      expect(founded_like_button).to have_selector '.like-button.clicked'
      expect(founded_like_button.find('.like-count').text.to_i).to eq 5

      founded_like_button.click
      founded_like_button = find("#record_#{top_record_id}")
      expect(founded_like_button).to_not have_selector '.like-button.clicked'
      expect(founded_like_button.find('.like-count').text.to_i).to eq 4

      # レコードページ
      top_record_link = all('.records-ranking_record').first
      top_record_link.click
      founded_like_button = find("#record_#{top_record_id}")
      expect(founded_like_button).to_not have_selector '.like-button.clicked'
      expect(founded_like_button.find('.like-count').text.to_i).to eq 4

      founded_like_button.click
      founded_like_button = find("#record_#{top_record_id}")
      expect(founded_like_button).to have_selector '.like-button.clicked'
      expect(founded_like_button.find('.like-count').text.to_i).to eq 5

      founded_like_button.click
      founded_like_button = find("#record_#{top_record_id}")
      expect(founded_like_button).to_not have_selector '.like-button.clicked'
      expect(founded_like_button.find('.like-count').text.to_i).to eq 4
    end
  end
end
