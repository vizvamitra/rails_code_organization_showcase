module AcmeIntegration
  module Identities
    class Sync
      def initialize(fetch_identity: Identities::Fetch.new,
                     store_identity: Identities::Store.new)
        @_fetch_identity = fetch_identity
        @_store_identity = store_identity
      end

      # @param identity_id [Integer]
      #
      # @return [void]
      # @raise [ActiveRecord::RecordNotFound]
      # @raise [Acme::Error]
      #
      def call(identity_id:)
        identity = Identity.find(identity_id)

        attributes = fetch(identity) || attributes_when_token_invalid(identity)
        ActiveRecord::Base.transaction { update(identity, attributes) }
      end

      private

      attr_reader :_fetch_identity, :_store_identity

      def fetch(identity)
        _fetch_identity.call(access_token: identity.access_token)
      rescue AcmeIntegration::AccessTokenInvalidError
        nil
      end

      def update(identity, attributes)
        _store_identity.call(client: identity.client, attributes:)
      end

      def attributes_when_token_invalid(identity)
        Attributes.new(
          id: identity.external_id,
          name: identity.name,
          avatar_url: identity.avatar_url,
          access_token: nil,
          permission_public_profile_read: false,
          permission_pages_read: false,
          permission_page_comments_read: false,
          permission_page_comments_manage: false
        )
      end
    end
  end
end
