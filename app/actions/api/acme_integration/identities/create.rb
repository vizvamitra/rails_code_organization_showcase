module Api
  module AcmeIntegration
    module Identities
      class Create
        def initialize(acme: ::AcmeIntegration::Interface.new)
          @_acme = acme
        end

        def call(client_id:, access_token:)
          _acme.create_identity(client_id:, access_token:)
        rescue ::AcmeIntegration::AccessTokenInvalidError,
               ::AcmeIntegration::PermissionMissingError
          raise HttpErrors::UnprocessableEntityError
        end

        private

        attr_reader :_acme
      end
    end
  end
end
