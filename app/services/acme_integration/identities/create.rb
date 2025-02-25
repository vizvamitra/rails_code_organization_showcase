module AcmeIntegration
  module Identities
    class Create
      def initialize(fetch_identity: Identities::Fetch.new,
                     store_identity: Identities::Store.new)
        @_fetch_identity = fetch_identity
        @_store_identity = store_identity
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
        ActiveRecord::Base.transaction { store(client, attributes) }
      end

      private

      attr_reader :_fetch_identity, :_store_identity

      def fetch(access_token)
        _fetch_identity.call(access_token:)
      end

      def store(client, attributes)
        _store_identity.call(client:, attributes:)
      end
    end
  end
end
