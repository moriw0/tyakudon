require 'rails_helper'

RSpec.describe Record do
  describe 'Validations' do
    context 'with valid information' do
      context ['with started_at', 'ended_at', 'wait_time', 'comment'].join(', ') do
        let!(:user) { create(:user) }
        let!(:ramen_shop) { create(:ramen_shop) }
        let!(:record) do
          user.records.build(
            started_at: Time.zone.now,
            ended_at: 10.minutes.from_now,
            wait_time: 600,
            comment: 'いただきます！',
            ramen_shop_id: ramen_shop.id
          )
        end

        it 'is valid' do
          expect(record).to be_valid
        end
      end

      context 'with a 8.4 MB image' do
        let!(:record) do
          build(:record,
                image: Rack::Test::UploadedFile.new(Rails.root.join('spec/fixtures/files/1000x800_8.4MB.png').to_s))
        end

        it 'is valid' do
          expect(record).to be_valid
        end
      end
    end

    context 'with invalid information' do
      context 'without a user' do
        let!(:record) { build(:record, user_id: nil) }

        it 'includes error message' do
          record.valid?
          expect(record.errors[:user]).to include('Userを入力してください。')
        end
      end

      context 'with a longer comment than maximum length 140' do
        let!(:record) { build(:record, comment: '*' * 141) }

        it 'includes error message' do
          record.valid?
          expect(record.errors[:comment]).to include('コメントは140文字以内で入力してください。')
        end
      end

      context 'with a 9.5 MB image' do
        let!(:record) do
          build(:record,
                image: Rack::Test::UploadedFile.new(Rails.root.join('spec/fixtures/files/1000x800_9.5MB.png').to_s))
        end

        it 'includes error message' do
          record.valid?
          expect(record.errors[:image]).to include '写真のファイルサイズは9MB以下にしてください。'
        end
      end

      context 'with a gif image' do
        let!(:record) do
          build(:record, image: Rack::Test::UploadedFile.new(Rails.root.join('spec/fixtures/files/ramen.gif').to_s))
        end

        it 'includes error message' do
          record.valid?
          expect(record.errors[:image]).to include 'アップロードできないファイル形式です。'
        end
      end

      context 'when stated_at is before now' do
        let!(:record) { build(:record, started_at: 1.minute.ago) }

        it 'includes error message' do
          record.valid?
          expect(record.errors[:started_at]).to include('接続時刻は作成時の現在時刻より数秒以内でなければなりません。')
        end
      end
    end
  end

  describe 'Custom Validations' do
    context 'when create' do
      context 'when started_at is not within a few seconds of the current time' do
        let!(:record) { build(:record, started_at: 10.seconds.ago) }

        it 'includes error message' do
          expect(record).to_not be_valid
          expect(record.errors[:started_at]).to include('接続時刻は作成時の現在時刻より数秒以内でなければなりません。')
        end
      end
    end

    context 'when update' do
      let!(:record) { create(:record) }

      context 'when ended_at is not within a few seconds of the current time' do
        before do
          record.assign_attributes(started_at: 10.seconds.ago, ended_at: 10.seconds.ago, calculate_action: true)
        end

        it 'includes error message' do
          record.valid?
          expect(record.errors[:ended_at]).to include('着丼時刻は更新時の現在時刻より数秒以内でなければなりません。')
        end
      end

      context 'when ended_at is not after started_at' do
        before { record.assign_attributes(started_at: Time.current, ended_at: 5.minutes.ago) }

        it 'includes error message' do
          record.valid?
          expect(record.errors[:ended_at]).to include('着丼時刻は接続時刻より後である必要があります。')
        end
      end

      context 'when wait_time is not the difference between ended_at and started_at' do
        before { record.assign_attributes(started_at: 5.minutes.ago, ended_at: Time.current, wait_time: 400) }

        it 'includes error message' do
          record.valid?
          expect(record.errors[:wait_time]).to include('待ち時間は着丼時刻と接続時刻の差である必要があります。')
        end
      end
    end
  end

  describe 'Model methods' do
    # rubocop:disable Rails/SkipsModelValidations
    describe '#favorite_records_from' do
      let!(:ramen_shops) { build_stubbed_list(:ramen_shop, 3, :many_shops) }
      let!(:user) { create(:user) }
      let!(:records) do
        ramen_shops.map { |shop|
          build_stubbed_list(:record, 3, :many_records, ramen_shop: shop, user: user, skip_validation: true)
        }.flatten
      end
      let!(:favorites) { ramen_shops.first(2).map { |shop| build_stubbed(:favorite, ramen_shop: shop, user: user) } }

      before do
        RamenShop.insert_all ramen_shops.map(&:attributes)
        described_class.insert_all records.map(&:attributes)
        Favorite.insert_all favorites.map(&:attributes)
      end

      it 'retrieves all records from favorited ramen_shops' do
        expect(described_class.favorite_records_from(user).count).to eq(6)

        described_class.favorite_records_from(user).each do |record|
          expect(user.favorite_shops).to include(record.ramen_shop)
        end
      end
    end

    describe '#order_by_most_likes' do
      let!(:ramen_shop) { create(:ramen_shop) }
      let!(:user) { create(:user) }
      let!(:users) { build_stubbed_list(:user, 5, :many_user) }
      let!(:records) { build_stubbed_list(:record, 5, :many_records, ramen_shop: ramen_shop, user: user) }
      let!(:likes) do
        records.each_with_index.map { |record, i|
          users.first(i).map do |user|
            build_stubbed(:like, record: record, user: user)
          end
        }.flatten
      end

      before do
        User.insert_all users.map(&:attributes)
        described_class.insert_all records.map(&:attributes)
        Like.insert_all likes.map(&:attributes)
      end

      it 'sorts records by the number of likes in descending order' do
        sorted_records = described_class.with_associations.order_by_most_likes
        expect(sorted_records[0].likes.size).to eq 4
        expect(sorted_records[1].likes.size).to eq 3
        expect(sorted_records[2].likes.size).to eq 2
        expect(sorted_records[3].likes.size).to eq 1
        expect(sorted_records[4].likes.size).to eq 0
      end
    end

    describe '#filter_by_shop_ids' do
      let!(:ramen_shops) { build_stubbed_list(:ramen_shop, 3, :many_shops) }
      let!(:user) { create(:user) }
      let!(:records) do
        ramen_shops.map { |shop|
          build_stubbed_list(:record, 2, :many_records, ramen_shop: shop, user: user)
        }.flatten
      end
      let!(:first_two_shop_ids) { ramen_shops.first(2).map(&:id) }

      before do
        RamenShop.insert_all ramen_shops.map(&:attributes)
        described_class.insert_all records.map(&:attributes)
      end

      it 'retrieves 4 records by first two shop ids in descending order' do
        filterd_records = described_class.filter_by_shop_ids(first_two_shop_ids)
        expect(filterd_records.size).to eq 4
        expect(filterd_records[0].ramen_shop_id).to eq first_two_shop_ids[1]
        expect(filterd_records[1].ramen_shop_id).to eq first_two_shop_ids[1]
        expect(filterd_records[2].ramen_shop_id).to eq first_two_shop_ids[0]
        expect(filterd_records[3].ramen_shop_id).to eq first_two_shop_ids[0]
      end
    end
    # rubocop:enable Rails/SkipsModelValidations
  end
end
