require 'rails_helper'

RSpec.describe LineStatus do
  let(:record) { FactoryBot.create(:record) }

  it 'is valid with record_id, line_number, line_type and comment' do
    line_status = record.line_statuses.build(
      line_number: 5,
      line_type: 1,
      comment: '並ぶぞ'
    )

    expect(line_status).to be_valid
  end

  it 'is valid with Bot' do
    line_status = FactoryBot.create(:line_status)
    expect(line_status).to be_valid
  end
end
