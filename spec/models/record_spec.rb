require 'rails_helper'

RSpec.describe Record do
  let(:user) { create(:user) }
  let(:record) { build(:record) }
  let(:ramen_shop) { create(:ramen_shop) }

  context 'with valid information' do
    it 'is valid with started_at, ended_at, wait_time and comment' do
      record = user.records.build(
        started_at: Time.zone.now,
        ended_at: 10.minutes.from_now,
        wait_time: 600,
        comment: 'いただきます！',
        ramen_shop_id: ramen_shop.id
      )
      expect(record).to be_valid
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

    it 'is invalid when stated_at is before now' do
      record = build(:record,
                     started_at: 1.minute.ago)
      record.valid?
      expect(record.errors[:started_at]).to include('は作成時の現在時刻より数秒以内でなければなりません')
    end
  end

  describe 'Custom Validations' do
    context 'when create' do
      it 'validates that started_at is within a few seconds of the current time' do
        record.started_at = 10.seconds.ago
        expect(record).to_not be_valid
        expect(record.errors[:started_at]).to include('は作成時の現在時刻より数秒以内でなければなりません')
      end
    end

    context 'when update' do
      before do
        record.save!
      end

      it 'validates that ended_at is within a few seconds of the current time' do
        record.calculate_action = true
        record.ended_at = 10.seconds.ago
        record.valid?
        expect(record.errors[:ended_at]).to include('は更新時の現在時刻より数秒以内でなければなりません')
      end

      it 'validates that ended_at is after started_at' do
        record.started_at = Time.current
        record.ended_at = 5.minutes.ago
        record.valid?
        expect(record.errors[:ended_at]).to include('はstarted_atより後である必要があります。')
      end

      it 'validates that wait_time is the difference between ended_at and started_at' do
        record.started_at = 5.minutes.ago
        record.ended_at = Time.current
        record.wait_time = 400
        record.valid?
        expect(record.errors[:wait_time]).to include('はended_atとstarted_atの差である必要があります。')
      end
    end
  end
end
