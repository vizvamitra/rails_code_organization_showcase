FactoryBot.define do
  factory :acme_integration_page, class: 'AcmeIntegration::Page' do
    client
    external_id { SecureRandom.hex(10) }
    public_id { SecureRandom.uuid }
    sequence(:name) { |n| "Page #{n}" }
    avatar_url { "https://example.com/avatar.png" }
    operable
    retrieve_comments { true }
    last_synced_at { 1.day.ago }

    trait(:undiscoverable) do
      access_provider { nil }
      discoverable { false }
      manager_role_granted { false }
      status { :undiscoverable }
    end

    trait(:inoperable) do
      access_provider { build(:acme_integration_identity) }
      discoverable { true }
      manager_role_granted { false }
      status { :inoperable }
    end

    trait(:operable) do
      access_provider { build(:acme_integration_identity) }
      discoverable { true }
      manager_role_granted { true }
      status { :operable }
    end
  end

  factory :acme_integration_page_attributes, class: 'AcmeIntegration::Pages::Attributes' do
    initialize_with { new(**attributes) }

    id { build(:acme_id) }
    sequence(:name) { |n| "User #{n}" }
    avatar_url { "https://example.com/avatar.png" }
    manager_role_granted { true }
  end
end
