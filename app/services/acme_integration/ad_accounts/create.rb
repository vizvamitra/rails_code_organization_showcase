# frozen_string_literal: true

module AcmeIntegration
  module AdAccount
    # Let's assume that to be able to operate an ad account, we need the
    # authorizing identity to:
    #
    # - have admin role in Acme system
    # - have access to an ad account within Acme system, specifically set up
    #   for us
    # - have a certain level of permissions over that ad account
    #
    # This class creates an identity if all of these requirements are met,
    # otherwise it returns a corresponding error.
    #
    # Also, this class showcases an implementation of a boundary between the
    # sub-systems
    #
    class Create
      SOURCE_NAME = 'acme'

      def initialize(fetch_identity: Identities::Fetch.new,
                     search_ad_account: AdAccounts::SearchConnectable.new,
                     ads_management: AdsManagement::Interface.new)
        @_fetch_identity = fetch_identity
        @_search_ad_account = search_ad_account
        @_ads_management = ads_management
      end

      # @param user_id [Integer]
      # @param access_token [String]
      #
      # @return [AcmeIntegration::AdAccount]
      #
      # @raise [ActiveRecord::RecordNotFound]
      # @raise [AcmeIntegration::AccessTokenInvalidError]
      # @raise [AcmeIntegration::PermissionMissingError]
      # @raise [AcmeIntegration::AdminRoleMissingError]
      # @raise [AcmeIntegration::AdAccountMissingError]
      # @raise [AcmeSDK::ApiError]
      #
      def call(user_id:, access_token:)
        user = User.find(user_id)

        identity_attrs = fetch_identity(access_token)
        raise AdminRoleMissingError if !identity_attrs.admin?

        ad_account_attrs = search_ad_account(access_token)
        raise AdAccountMissingError if ad_account.nil?

        ActiveRecord::Base.transaction do
          ad_account = create_ad_account(user, identity_attrs, ad_account_attrs)
          notify_asset_created(user, ad_account)

          ad_account
        end
      end

      private

      attr_reader :_fetch_identity, :_search_ad_account, :_ads_management

      def fetch_identity(access_token)
        _fetch_identity.call(access_token:)
      end

      def search_ad_account(access_token)
        _search_ad_account.call(access_token:)
      end

      def create_ad_account(user, identity_attrs, ad_account_attrs)
        user.acme_ad_accounts.create!(
          external_id: ad_account_attrs.id,
          public_id: SecureRandom.uuid,
          identity_external_id: identity_attrs.id,
          access_token: identity_attrs.access_token,
          access_status: :acquired,
          name: ad_account_attrs.name,
          status: ad_account_attrs.status,
          ads_syncronization: false
        )
      end

      # This is essentially the same as publishing an "AdAccountCreated" message
      # in event-based architecture, but in this showcase I avoid events for
      # simplicity and wider adoptability
      #
      def notify_asset_created(ad_account)
        _ads_management.create_asset(
          user_id: ad_account.user_id,
          source: SOURCE_NAME,
          public_id: ad_account.public_id,
          name: ad_account.name
        )
      end
    end
  end
end
