require 'rails_helper'

RSpec.describe Like do
  let(:user) { create(:user) }
  let(:other_user) { create(:other_user) }
  let(:record) { create(:record, user: other_user) }

  it 'is valid with user and record' do
    like = user.likes.build(record: record)
    expect(like).to be_valid
  end

  it 'is invalid without record' do
    like = user.likes.build(record: nil)
    like.valid?
    expect(like.errors[:record]).to include 'を入力してください'
  end

  it 'is invalid without user' do
    like = described_class.new(record: record, user: nil)
    like.valid?
    expect(like.errors[:user]).to include 'を入力してください'
  end
end
