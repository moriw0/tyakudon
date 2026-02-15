FactoryBot.define do
  factory :cheer_message do
    content { 'MyText' }
    role { :user }
    record
  end
end
