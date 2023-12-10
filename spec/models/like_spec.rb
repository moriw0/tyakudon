require 'rails_helper'

RSpec.describe Like do
  describe 'Validations' do
    context 'with user and record' do
      let!(:user) { create(:user) }
      let!(:other_user) { create(:other_user) }
      let!(:record) { create(:record, user: other_user) }
      let!(:like) { user.likes.build(record: record) }

      it 'is valid' do
        expect(like).to be_valid
      end
    end

    context 'without record' do
      let!(:user) { create(:user) }
      let!(:like) { user.likes.build(record: nil) }

      it 'includes error message' do
        like.valid?
        expect(like.errors[:record]).to include 'を入力してください'
      end
    end

    context 'without user' do
      let!(:record) { create(:record) }
      let!(:like) { described_class.new(record: record, user: nil) }

      it 'includes error message' do
        like.valid?
        expect(like.errors[:user]).to include 'を入力してください'
      end
    end
  end

  describe 'Model Methods' do
    let!(:user) { create(:user) }
    let!(:other_user) { create(:other_user) }
    let!(:record) { create(:record, user: other_user) }

    describe '#likes?' do
      context 'if the user likes the record' do
        it 'returns true' do
          user.like_records << record
          expect(user.likes?(record)).to be true
        end
      end

      context 'if the user does not like the record' do
        it 'returns false' do
          expect(user.likes?(record)).to be false
        end
      end
    end

    describe '#add_like' do
      it 'adds a like to the user' do
        user.add_like(record)
        expect(user.likes?(record)).to be true
      end

      it 'does not add a duplicate like' do
        user.add_like(record)
        user.add_like(record)
        expect(user.like_records.count).to eq 1
      end
    end

    describe '#remove_like' do
      context 'if user added a like' do
        before { user.add_like(record) }

        it 'removes the like' do
          user.remove_like(record)
          expect(user.likes?(record)).to be false
        end
      end

      context 'if the like does not exist' do
        it 'does nothing' do
          expect { user.remove_like(record) }.to_not change(user.like_records, :count)
        end
      end
    end
  end
end
