# frozen_string_literal: true

module Api
  module AcmeIntegration
    module AdAccounts
      class Create
        def initialize(acme_integration: ::AcmeIntegration::Interface.new)
          @_acme_integration = acme_integration
        end

        # @param user_id [Integer]
        # @param access_token [String]
        #
        # @return [AcmeIntegration::AdAccount]
        #
        # @raise [Api::Errors::NotFoundError]
        # @raise [Api::Errors::InternalServerError]
        # @raise [Api::Errors::UnprocessableEntityError]
        #
        def call(user_id:, access_token:)
          create_ad_account(user_id, access_token)
        rescue ActiveRecord::RecordNotFound
          raise Api::Errors::NotFoundError
        rescue AcmeSDK::ApiError
          raise Api::Errors::InternalServerError
        rescue ::AcmeIntegration::AccessTokenInvalidError
          raise Api::Erorrs::UnprocessableEntityError, :acme_access_token_invalid
        rescue ::AcmeIntegration::PermissionMissingError
          raise Api::Erorrs::UnprocessableEntityError, :acme_permission_missing
        rescue ::AcmeIntegration::IdentityNotFoundError
          raise Api::Erorrs::UnprocessableEntityError, :acme_identity_not_found
        rescue ::AcmeIntegration::AdminRoleMissingError
          raise Api::Erorrs::UnprocessableEntityError, :acme_admin_role_missing
        rescue ::AcmeIntegration::AdAccountMissingError
          raise Api::Erorrs::UnprocessableEntityError, :acme_ad_account_missing
        end

        private

        attr_reader :_acme_integration

        def create_ad_account(user_id, access_token)
          _acme_integration.create_ad_account(user_id:, access_token:)
        end
      end
    end
  end
end
