module AcmeIntegration
  module Identities
    class Create
      def initialize(fetch_identity: Identities::Fetch.new,
                     store_identity: Identities::Store.new,
                     discover_pages: Pages::Discover.new)
        @_fetch_identity = fetch_identity
        @_store_identity = store_identity
        @_discover_pages = discover_pages
      end

      # @param client_id [Integer]
      # @param access_token [String]
      #
      # @return [AcmeIntegration::Identity]
      # @raise [ActiveRecord::RecordNotFound]
      # @raise [AcmeIntegration::AccessTokenInvalidError]
      # @raise [Acme::Error]
      #
      def call(client_id:, access_token:)
        client = Client.find(client_id)

        attributes = fetch(access_token)
        identity = ActiveRecord::Base.transaction { store(client, attributes) }

        discover_pages(identity)

        identity
      end

      private

      attr_reader :_fetch_identity, :_store_identity, :_discover_pages

      def fetch(access_token)
        _fetch_identity.call(access_token:)
      end

      def store(client, attributes)
        _store_identity.call(client:, attributes:)
      end

      def discover_pages(identity)
        _discover_pages.call(identity_id: identity.id)
      end
    end
  end
end
