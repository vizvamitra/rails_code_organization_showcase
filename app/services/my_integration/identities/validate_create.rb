module MyIntegration
  module Identities
    # To operate an identity we need this identity to:
    #
    # - have admin privileges within the third-party system we integrate with
    # - posess a specific asset within that system
    # - have certain level of access to that asset
    #
    # This class is responsible for validating that those preconditions are
    # met and, in case they are not, returning details on what's missing
    #
    class ValidateCreate
      include Dry::Monads[:result]
      include Dry::Monads::Do.for(:call)

      def initialize(fetch_identity: Fetch.new,
                     search_asset: Assets::SearchOperable.new)
        @do_fetch_identity = fetch_identity
        @do_search_asset = search_asset
      end

      # @param account_id [Integer]
      # @param external_id [String]
      # @param access_token [String]
      #
      # @return [Success<>,Failure<Symbol>]
      # @raise [SomeApiClient::ApiError]
      # @raise [ActiveRecord::RecordNotFound]
      #
      def call(account_id:, external_id:, access_token:)
        validate_account_exists(account_id)

        yield fetch_identity(external_id, access_token)
        yield search_asset(external_id, access_token)

        Success()
      end

      private

      attr_reader :do_fetch_identity, :do_search_asset

      def fetch_identity(identity_id, access_token)
        identity = do_fetch_identity.call(
          external_id: identity_id,
          access_token: access_token
        )

        identity.admin? ? Success(identity) : Failure(:admin_role_missing)
      rescue AccessTokenInvalidError
        Failure(:access_token_invalid)
      rescue PermissionMissingError
        Failure(:permission_missing)
      rescue IdentityNotFoundError
        Failure(:identity_not_found)
      end

      def search_asset(identity_id, access_token)
        asset = do_search_asset.call(
          identity_id: identity_id,
          access_token: access_token
        )

        asset ? Success(asset) : Failure(:asset_missing)
      end

      def validate_account_exists(account_id)
        Account.find(account_id)
      end
    end
  end
end
