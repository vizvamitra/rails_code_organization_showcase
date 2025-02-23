FactoryBot.define do
  factory :acme_id, class: String do
    id { SecureRandom.hex(16) }
    initialize_with { new(id) }
  end

  factory :acme_api_entity, class: Hash do
    initialize_with { new(**attributes.stringify_keys) }

    factory :acme_api_identity do
      id { build(:acme_id) }
      sequence(:name) { |n| "Name #{n}" }
      avatar_url { "https://example.com/avatar.png" }
      permissions do
        [
          ("public_profile_read" if public_profile_read),
          ("pages_read" if pages_read),
          ("page_comments_read" if page_comments_read),
          ("page_comments_manage" if page_comments_manage)
        ].compact
      end

      transient do
        public_profile_read { true }
        pages_read { true }
        page_comments_read { true }
        page_comments_manage { true }
      end
    end
  end
end
