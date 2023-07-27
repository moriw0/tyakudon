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

    it 'is valid with a 4.2 MB image' do
      record = build(:record)
      record.image = Rack::Test::UploadedFile.new(Rails.root.join('spec/fixtures/files/1000x800_4.2MB.png').to_s)
      expect(record).to be_valid
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

    it 'is invalid with a 5.2 MB image' do
      record = build(:record)
      record.image = Rack::Test::UploadedFile.new(Rails.root.join('spec/fixtures/files/1000x800_5.3MB.png').to_s)
      record.valid?
      expect(record.errors[:image]).to include 'は5MB以下である必要があります'
    end

    it 'is invalid with a gif image' do
      record = build(:record)
      record.image = Rack::Test::UploadedFile.new(Rails.root.join('spec/fixtures/files/ramen.gif').to_s)
      record.valid?
      expect(record.errors[:image]).to include 'のフォーマットが不正です'
    end
  end
end
