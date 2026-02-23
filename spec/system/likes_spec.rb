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
    scenario 'user redirects to login_path when click like button' do
      visit new_records_path
      all('.like-button').first.click
      expect(page).to have_content 'ログインが必要です'
    end
  end

  context 'with login other users' do
    before { log_in_as(user) }

    scenario 'user adds and removes a like in both feed page and the record page' do
      # フィードページ
      visit new_records_path
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
      top_record_link = all('.records-record').first
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
