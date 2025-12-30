module AcmeIntegration
  module Pages
    class Discover
      def initialize(sync_identity: Identities::Sync.new,
                     fetch_all: FetchAll.new,
                     actualize: Actualize.new,
                     update_access_details: UpdateAccessDetails.new)
        @_sync_identity = sync_identity
        @_fetch_all = fetch_all
        @_actualize = actualize
        @_update_access_details = update_access_details
      end

      # @param identity_id [Integer]
      #
      # @return [void]
      # @raise [ActiveRecord::RecordNotFound]
      # @raise [AcmeIntegration::AccessTokenInvalidError]
      # @raise [AcmeIntegration::PermissionMissingError]
      # @raise [Acme::Error]
      #
      def call(identity_id:)
        identity = Identity.find(identity_id)

        identity = sync(identity)

        discoverable = fetch_pages(identity)
        undiscoverable = undiscoverable_pages(identity, discoverable)

        ActiveRecord::Base.transaction do
          discoverable.each { |attributes| actualize_page(identity, attributes) }
          undiscoverable.each { |page| cleanup_access_provider(page) }
        end
      end

      private

      attr_reader :_sync_identity, :_fetch_all, :_actualize, :_update_access_details

      def sync(identity)
        _sync_identity.call(identity:)
      end

      def fetch_pages(identity)
        return [] unless identity.can_discover_pages?

        _fetch_all.call(access_token: identity.access_token)
      end

      def undiscoverable_pages(identity, discoverable)
        identity.pages.where.not(facebook_id: discoverable.map(&:id))
      end

      def actualize_page(identity, attributes)
        _actualize.call(identity:, attributes:)
      end

      def cleanup_access_provider(page)
        _update_access_details.call(
          page:,
          access_provider: nil,
          discoverable: false,
          manager_role_granted: false
        )
      end
    end
  end
end
