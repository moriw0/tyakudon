require 'rails_helper'

RSpec.describe Record do
  let(:user) { create(:user) }
  let(:ramen_shop) { create(:ramen_shop) }

  context 'with valid information' do
    it 'is valid with started_at, ended_at, wait_time and comment' do
      record = user.records.build(
        started_at: 11.minutes.ago,
        ended_at: 1.minute.ago,
        wait_time: 600,
        comment: 'いただきます！',
        ramen_shop_id: ramen_shop.id
      )
      expect(record).to be_valid
    end

    it 'returns the most recent first' do
      create_list(:many_records, 10, user: user)
      expect(create(:most_recent, user: user)).to eq described_class.first
    end
  end

  context 'with invalid information' do
    it 'is invalid without a user' do
      record = build(:record, user_id: nil)
      record.valid?
      expect(record.errors[:user]).to include('を入力してください')
    end

    it 'is invalid with a longer comment than maximum length 140' do
      record = build(:record, comment: '*' * 141)
      record.valid?
      expect(record.errors[:comment]).to include('は140文字以内で入力してください')
    end
  end
end
