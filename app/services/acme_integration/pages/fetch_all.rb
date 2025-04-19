module AcmeIntegration
  module Pages
    class FetchAll
      def initialize(api_client: Acme::ApiClient.new)
        @_api_client = api_client
      end

      # @param access_token [String]
      #
      # @return [Array<AcmeIntegration::Pages::Attributes>]
      # @raise [AcmeIntegration::AccessTokenInvalidError]
      # @raise [AcmeIntegration::PermissionMissingError]
      # @raise [Acme::Error]
      #
      def call(access_token:)
        fetch(access_token).map { |raw| parse(raw) }
      rescue Acme::AuthenticationError
        raise AccessTokenInvalidError
      rescue Acme::ClientError => e
        raise (e.message =~ /permission missing/ ? PermissionMissingError : e)
      end

      private

      attr_reader :_api_client

      def fetch(access_token)
        _api_client.get_pages(access_token:)["data"]
      end

      def parse(raw)
        Attributes.new(
          id: raw["id"],
          name: raw["name"],
          avatar_url: raw["avatar_url"],
          manager_role_granted: raw["roles"].include?("manager")
        )
      end
    end
  end
end
