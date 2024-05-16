# frozen_string_literal: true

module AcmeIntegration
  module Identities
    class Fetch
      def initialize(api_client: Acme::ApiClient.new)
        @api_client = api_client
      end

      # @param access_token [String]
      #
      # @return [AcmeIntegration::Identities::Attributes]
      #
      # @raise [AcmeIntegration::AccessTokenInvalidError]
      # @raise [AcmeIntegration::PermissionMissingError]
      # @raise [AcmeSDK::ApiError]
      #
      def call(access_token:)
        raw_identity = fetch(access_token)
        parse(raw_identity, access_token)
      end

      private

      attr_reader :api_client

      def fetch(access_token)
        api_client.identity(access_token:, fields: 'id,name,avatar_url,roles')
      rescue AcmeSDK::AuthenticationError
        raise AccessTokenInvalidError
      rescue AcmeSDK::ClientError => e
        case e.message
        when /permission missing/ then raise PermissionMissingError
        else raise
        end
      end

      def parse(raw_identity, access_token)
        Attributes.new(
          id: raw_identity['id'],
          name: raw_identity['name'],
          avatar_url: raw_identity['avatar_url'],
          access_token:,
          roles: raw_identity['roles']
        )
      end
    end
  end
end
