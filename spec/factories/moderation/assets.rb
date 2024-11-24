FactoryBot.define do
  factory :moderation_asset, class: 'Moderation::Asset' do
    source { :acme }
    sequence(:public_id)
    sequence(:title) { |n| "Page #{n}" }
    avatar_url { "https://example.com/avatar.png" }
    external_id { SecureRandom.hex(10) }
    moderated { false }
    access_acquired { false }
    client
  end
end
