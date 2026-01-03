module AcmeIntegration
  module Pages
    class Actualize
      def initialize(is_preferred_access_provider: IsPreferredAccessProvider.new,
                     update_public_details: UpdatePublicDetails.new,
                     update_access_details: UpdateAccessDetails.new)
        @_is_preferred_access_provider = is_preferred_access_provider
        @_update_public_details = update_public_details
        @_update_access_details = update_access_details
      end

      # @param identity [AcmeIntegration::Identity]
      # @param attributes [AcmeIntegration::Pages::Attributes]
      #
      # @return [AcmeIntegration::Page, nil]
      #
      def call(identity:, attributes:)
        page = find_or_build(identity.client_id, attributes.id)
        return unless preferred_provider?(page, identity, attributes)

        update_public_details(page, attributes)
        update_access_details(page, identity, attributes)

        page.update!(last_synced_at: Time.now)

        page
      end

      private

      attr_reader :_is_preferred_access_provider, :_update_public_details,
                  :_update_access_details

      def find_or_build(client_id, acme_id)
        Page
          .create_with(public_id: SecureRandom.uuid)
          .find_or_initialize_by(client_id:, acme_id:)
      end

      def preferred_provider?(page, identity, attributes)
        _is_preferred_access_provider.call(
          page:,
          candidate: identity,
          operable_by_candidate: attributes.manager_role_granted
        )
      end

      def update_public_details(page, attributes)
        _update_public_details.call(
          page:,
          name: attributes.name,
          avatar_url: attributes.avatar_url
        )
      end

      def update_access_details(page, access_provider, attributes)
        _update_access_details.call(
          page:,
          access_provider:,
          discoverable: true,
          manager_role_granted: attributes.manager_role_granted
        )
      end
    end
  end
end
