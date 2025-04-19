module AcmeIntegration
  module Identities
    class Fetch
      def initialize(api_client: Acme::ApiClient.new)
        @_api_client = api_client
      end

      # @param access_token [String]
      #
      # @return [AcmeIntegration::Identities::Attributes]
      # @raise [AcmeIntegration::AccessTokenInvalidError]
      # @raise [AcmeIntegration::PermissionMissingError]
      # @raise [Acme::Error]
      #
      def call(access_token:)
        raw_response = fetch(access_token)
        parse(raw_response, access_token)
      rescue Acme::AuthenticationError
        raise AccessTokenInvalidError
      rescue Acme::ClientError => e
        raise (e.message =~ /permission missing/ ? PermissionMissingError : e)
      end

      private

      attr_reader :_api_client

      def fetch(access_token)
        _api_client.get_identity(access_token:)["data"]
      end

      def parse(raw, access_token)
        Attributes.new(
          id: raw["id"],
          access_token:,
          name: raw["name"],
          avatar_url: raw["avatar_url"],
          permission_public_profile_read: permission?(raw, :public_profile_read),
          permission_pages_read: permission?(raw, :pages_read),
          permission_page_comments_read: permission?(raw, :page_comments_read),
          permission_page_comments_manage: permission?(raw, :page_comments_manage)
        )
      end

      def permission?(raw, name)
        raw["permissions"].include?(name.to_s)
      end
    end
  end
end
