FactoryBot.define do
  factory :acme_integration_page, class: 'AcmeIntegration::Page' do
    client
    identity
    external_id { SecureRandom.hex(10) }
    sequence(:name) { |n| "Page #{n}" }
    avatar_url { "https://example.com/avatar.png" }
    operable
    retrieve_comments { true }

    trait(:undiscoverable) do
      manager_access_granted { false }
      discoverable { false }
      status { :undiscoverable }
    end

    trait(:inoperable) do
      manager_access_granted { false }
      discoverable { true }
      status { :inoperable }
    end

    trait(:operable) do
      manager_access_granted { true }
      discoverable { true }
      status { :operable }
    end

    trait(:access_lost) do
      # TODO
    end
  end
end
