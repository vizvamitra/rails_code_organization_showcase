module Api
  module MyIntegration
    module Identities
      class Validate
        def initialize(my_integration: ::MyIntegration::Interface.new)
          @my_integration = my_integration
        end

        # @param account_id [Integer]
        # @param external_id [String]
        # @param access_token [String]
        #
        # @return [Success<>,Failure<Symbol>]
        # @raise [Api::Errors::NotFoundError]
        # @raise [Api::Errors::BadRequestError]
        #
        def call(account_id:, external_id:, access_token:)
          validate_identity(account_id, external_id, access_token)
        rescue ActiveRecord::RecordNotFound
          raise Api::Errors::NotFoundError
        rescue SomeApiClient::ApiError
          raise Api::Errors::InternalServerError
        end

        private

        attr_reader :my_integration

        def validate_identity(account_id, external_id, access_token)
          my_integration.validate_identity(
            account_id: account_id,
            external_id: external_id,
            access_token: access_token
          )
        end
      end
    end
  end
end
