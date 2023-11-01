FactoryBot.define do
  factory :line_status do
    line_number { 5 }
    line_type { 'inside_the_store' }
    comment { '並ぶぞ' }
    image { Rack::Test::UploadedFile.new(Rails.root.join('spec/fixtures/files/1000x800_4.2MB.png').to_s) }
    record
  end
end
