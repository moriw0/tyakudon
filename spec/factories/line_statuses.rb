FactoryBot.define do
  factory :line_status do
    line_number { 5 }
    line_type { 1 }
    comment { '並ぶぞ' }
    record
  end
end
