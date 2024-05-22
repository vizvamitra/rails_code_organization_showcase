# frozen_string_literal: true

module AcmeIntegration
  module Ads
    class ScheduleSync
      # @return [Void]
      #
      def call
        active_ad_accounts.ids.each { |id| schedule(id) }
      end

      private

      # We sync ads if:
      #
      # 1. Syncronization is turned on by user
      # 2. Identity credentials are valid
      #
      # Assume that AdAccount status and access are synced elsewhere by cron
      #
      def active_ad_accounts
        AdAccount
          .where(ads_syncronization: true, access_status: :acquired)
          .includes(:identity)
      end

      def schedule(ad_account_id)
        AcmeIntegration::SyncAdsJob.perform_async(ad_account_id)
      end
    end
  end
end
