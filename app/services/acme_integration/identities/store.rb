module AcmeIntegration
  module Identities
    class Store
      def initialize(refresh_status: Identities::RefreshStatus.new)
        @_refresh_status = refresh_status
      end

      # @param client [Client]
      # @param attributes [AcmeIntegration::Identities::Attributes]
      #
      # @return [AcmeIntegration::Identity]
      #
      def call(client:, attributes:)
        identity = find_or_build(client, attributes.id)

        update_attributes(identity, attributes)
        refresh_status(identity)

        identity
      end

      private

      attr_reader :_refresh_status

      def find_or_build(client, acme_id)
        client.acme_identities.find_or_initialize_by(acme_id:)
      end

      def update_attributes(identity, attributes)
        identity.update!(
          name: attributes.name,
          avatar_url: attributes.avatar_url,
          access_token: attributes.access_token,
          permission_public_profile_read: attributes.permission_public_profile_read,
          permission_pages_read: attributes.permission_pages_read,
          permission_page_comments_read: attributes.permission_page_comments_read,
          permission_page_comments_manage: attributes.permission_page_comments_manage
        )
      end

      def refresh_status(identity)
        _refresh_status.call(identity:)
      end
    end
  end
end
