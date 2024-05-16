# frozen_string_literal: true

module AcmeIntegration
  module Ads
    class Sync
      def initialize(fetch_ads: Fetch.new)
        @_fetch_ads = fetch_ads
      end

      # @param access_token [String]
      #
      # @return [Void]
      #
      # @raise [AcmeIntegration::AccessTokenInvalidError]
      # @raise [AcmeIntegration::PermissionMissingError]
      # @raise [AcmeIntegration::AdAccountArchivedError]
      # @raise [AcmeSDK::ApiError]
      #
      def call(ad_account_id:)
        ad_account = AdAccount.active.find_by(id: ad_account_id)
        return unless ad_account

        ads = fetch_ads(ad_account)

        ActiveRecord::Base.transaction do
          sync_active(ad_account, ads)
          deactivate_inactive(ad_account, ads)
        end
      end

      private

      attr_reader :api_client

      def fetch_ads(ad_account)
        _fetch_ads.call(
          ad_account_id: ad_account.external_id,
          access_token: ad_account.access_token
        )
      end

      def sync_active(ad_account, ads)
        ads.each do |ad|
          ad_account
            .ads
            .find_or_initialize_by(external_id: ad.id)
            .update!(status: :active, **ad.to_h.except(:id, :status))
        end
      end

      def deactivate_inactive(ad_account, active_ads)
        ad_account
          .ads
          .active
          .where.not(external_id: active_ads.map(&:id))
          .update_all(status: :inactive, updated_at: Time.current)
      end
    end
  end
end
