FactoryBot.define do
  factory :line_status do
    line_number { 5 }
    line_type { 'inside_the_store' }
    comment { '並ぶぞ' }
    record
  end
end
