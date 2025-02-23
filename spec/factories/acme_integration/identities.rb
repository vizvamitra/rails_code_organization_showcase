FactoryBot.define do
  factory :acme_integration_identity, class: 'AcmeIntegration::Identity' do
    client
    external_id { build(:acme_id) }
    sequence(:name) { |n| "User #{n}" }
    avatar_url { "https://example.com/avatar.png" }
    full_access

    trait :full_access do
      access_token { SecureRandom.hex(16) }
      permission_public_profile_read { true }
      permission_pages_read { true }
      permission_page_comments_read { true }
      permission_page_comments_manage { true }
      access_token_valid { true }
      can_discover_pages { true }
      can_moderate_comments { true }
      access_status { :full }
    end

    trait :partial_access do
      permission_page_comments_manage { false }
      can_moderate_comments { false }
      access_status { :partial }
    end

    trait :revoked_access do
      access_token { nil }
      permission_public_profile_read { false }
      permission_pages_read { false }
      permission_page_comments_read { false }
      permission_page_comments_manage { false }
      access_token_valid { false }
      can_discover_pages { false }
      can_moderate_comments { false }
      access_status { :revoked }
    end
  end

  factory :acme_integration_identity_attributes, class: 'AcmeIntegration::Identities::Attributes' do
    initialize_with { new(**attributes) }

    id { build(:acme_id) }
    sequence(:name) { |n| "User #{n}" }
    avatar_url { "https://example.com/avatar.png" }
    access_token { SecureRandom.hex(16) }
    permission_public_profile_read { true }
    permission_pages_read { true }
    permission_page_comments_read { true }
    permission_page_comments_manage { true }
  end
end
