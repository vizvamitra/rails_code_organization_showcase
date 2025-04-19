FactoryBot.define do
  factory :moderation_asset, class: 'Moderation::Asset' do
    client
    public_id { SecureRandom.uuid }
    source { :acme }
    sequence(:title) { |n| "Page #{n}" }
    sequence(:url) { |n| "https://example.com/#{n}" }
    avatar_url { "https://example.com/avatar.png" }
    moderated { false }
    access_acquired { false }
  end
end
