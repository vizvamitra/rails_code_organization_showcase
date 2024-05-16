# frozen_string_literal: true

module AcmeIntegration
  class SyncAdsJob
    include Sidekiq::Job

    def perform(ad_account_id)
      acme_integration.sync_ads(ad_account_id:)
    rescue ::AcmeDSK::ClientError, ::AcmeIntegration::Error
      # Retries are useless in those cases
    end

    private

    def acme_integration
      ::AcmeIntegration::Interface.new
    end
  end
end
