# frozen_string_literal: true

module AcmeIntegration
  class Interface < ::Subsystems::Interface
    logging_prefix 'AcmeIntegration'
    filtered_params %i[access_token]

    # ...

    # @param user_id [Integer]
    # @param access_token [String]
    #
    # @return [AcmeIntegration::AdAccount]
    #
    # @raise [ActiveRecord::RecordNotFound]
    # @raise [AcmeIntegration::AccessTokenInvalidError]
    # @raise [AcmeIntegration::PermissionMissingError]
    # @raise [AcmeIntegration::IdentityNotFoundError]
    # @raise [AcmeIntegration::AdminRoleMissingError]
    # @raise [AcmeIntegration::AdAccountMissingError]
    # @raise [AcmeSDK::ApiError]
    #
    def create_ad_account(**args)
      with_logging { AdAccounts::Create.new.call(**args) }
    end

    # @param ad_account_id [Integer]
    #
    # @return [Void]
    #
    # @raise [AcmeIntegration::AccessTokenInvalidError]
    # @raise [AcmeIntegration::PermissionMissingError]
    # @raise [AcmeIntegration::AdAccountArchivedError]
    # @raise [Acme::ApiError]
    #
    def sync_ads(**args)
      with_logging { Ads::Sync.new.call(**args) }
    end

    # @return [Void]
    #
    def schedule_ads_sync(**args)
      with_logging { Ads::ScheduleSync.new.call(**args) }
    end

    # @param public_id [String]
    #
    # @return [Void]
    # @raise [ActiveRecord::RecordNotFound]
    #
    def deactivate_ad_account_sync(**args)
      with_logging { AdAccounts::DeactivateSync.new.call(**args) }
    end
  end
end
