module MyIntegration
  module Identities
    class Fetch
      def initialize(api_client: SomeApiClient.new)
        @api_client = api_client
      end

      # @param external_id [String]
      # @param access_token [String]
      #
      # @return [MyIntegration::Identities::Attributes]
      # @raise [MyIntegration::AccessTokenInvalidError]
      # @raise [MyIntegration::PermissionMissingError]
      # @raise [MyIntegration::IdentityNotFoundError]
      # @raise [SomeApiClient::ApiError]
      #
      def call(external_id:, access_token:)
        raw_identity = fetch(external_id, access_token)
        parse(raw_identity, access_token)
      end

      private

      attr_reader :api_client

      def fetch(external_id, access_token)
        api_client.identity(external_id: external_id, access_token: access_token)
      rescue SomeApiClient::AuthenticationError
        raise AccessTokenInvalidError
      rescue SomeApiClient::ClientError => e
        case e.message
        when /permission missing/ then raise PermissionMissingError
        when /not found/ then raise IdentityNotFoundError
        else raise
        end
      end

      def parse(raw_identity, access_token)
        Attributes.new(
          id: raw_identity['id'],
          name: raw_identity['name'],
          avatar_url: raw_identity['avatar_url'],
          access_token: access_token,
          roles: raw_identity['roles']
        )
      end
    end
  end
end
