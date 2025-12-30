FactoryBot.define do
  factory :moderation_comment_feed, class: 'Moderation::CommentFeed' do
    client
    platform { :acme }
    public_id { SecureRandom.uuid }
    upstream_id { SecureRandom.hex(10) }
    sequence(:title) { |n| "Page #{n}" }
    sequence(:url) { |n| "https://example.com/#{n}" }
    avatar_url { "https://example.com/avatar.png" }
    moderated { false }
    connected { false }
  end
end
