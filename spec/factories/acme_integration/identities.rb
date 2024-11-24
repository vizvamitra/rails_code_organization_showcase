FactoryBot.define do
  factory :acme_integration_identity, class: 'AcmeIntegration::Identity' do
    client
    external_id { SecureRandom.hex }
    sequence(:name) { |n| "Page #{n}" }
    avatar_url { "https://example.com/avatar.png" }
    access_token { SecureRandom.hex(16) }
    permission_public_profile_read { false }
    permission_pages_read { false }
    permission_page_comments_read { false }
    permission_page_comments_manage { false }
    access_token_valid { true }
    can_view_public_profile { true }
    can_moderate_comments { true }
  end
end
