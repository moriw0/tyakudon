require 'rails_helper'

RSpec.describe Record do
  let(:ramen_shop) { FactoryBot.create(:ramen_shop) }

  it 'is valid with started_at, ended_at, wait_time and comment' do
    record = ramen_shop.records.build(
      started_at: 11.minute.ago,
      ended_at: 1.minute.ago,
      wait_time: 600,
      comment: 'いただきます！'
    )
    expect(record).to be_valid
  end

  it 'is valid with Bot' do
    record = FactoryBot.create(:record)
    expect(record).to be_valid
  end
end
