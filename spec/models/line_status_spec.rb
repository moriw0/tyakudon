require 'rails_helper'

RSpec.describe LineStatus do
  let(:record) { create(:record) }
  let(:line_status) { build(:line_status) }

  it 'is valid with record_id, line_number, line_type comment, and 4.2MB image' do
    line_status = record.line_statuses.build(
      line_number: 5,
      line_type: 'inside_the_store',
      comment: '並ぶぞ',
      image: Rack::Test::UploadedFile.new(Rails.root.join('spec/fixtures/files/1000x800_4.2MB.png').to_s)
    )

    expect(line_status).to be_valid
  end

  it 'is invalid with no-existing line_type' do
    expect { line_status.line_type = 'invalid' }.to raise_error(ArgumentError, "'invalid' is not a valid line_type")
  end

  it 'is invalid with blank line_number' do
    line_status.line_number = ''
    line_status.valid?
    expect(line_status.errors[:line_number]).to include 'は数値で入力してください'
  end

  it 'is invalid with string line_number' do
    line_status.line_number = '３'
    line_status.valid?
    expect(line_status.errors[:line_number]).to include 'は数値で入力してください'
  end

  it 'is invalid with line_number less than 0' do
    line_status.line_number = -1
    line_status.valid?
    expect(line_status.errors[:line_number]).to include 'は0以上の値にしてください'
  end

  it 'is invalid with longer comment' do
    line_status.comment = 'a' * 141
    line_status.valid?
    expect(line_status.errors[:comment]).to include '最大140文字まで使えます'
  end

  it 'is invalid with a 5.2 MB image' do
    line_status.image = Rack::Test::UploadedFile.new(Rails.root.join('spec/fixtures/files/1000x800_5.3MB.png').to_s)
    line_status.valid?
    expect(line_status.errors[:image]).to include 'は5MB以下である必要があります'
  end

  it 'is invalid with a gif image' do
    line_status.image = Rack::Test::UploadedFile.new(Rails.root.join('spec/fixtures/files/ramen.gif').to_s)
    line_status.valid?
    expect(line_status.errors[:image]).to include 'のフォーマットが不正です'
  end
end
