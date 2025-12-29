FactoryBot.define do
  factory :moderation_asset, class: 'Moderation::Asset' do
    client
    source { :acme }
    public_id { SecureRandom.uuid }
    external_id { SecureRandom.hex(10) }
    sequence(:title) { |n| "Page #{n}" }
    sequence(:url) { |n| "https://example.com/#{n}" }
    avatar_url { "https://example.com/avatar.png" }
    active { false }
    access_acquired { false }
  end
end
