FactoryBot.define do
  factory :user do
    sequence(:email_address) { |n| "user#{n}@example.com" }
    password { "12345678" }
    password_confirmation { password }
    client
  end
end
