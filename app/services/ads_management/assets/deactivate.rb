# frozen_string_literal: true

module AdsManagement
  module Assets
    # This class showcases an implementation of a boundary between subsystems
    #
    class Deactivate
      def initialize(acme_integration: AcmeIntegration::Interface.new)
        @_acme_integration = acme_integration
      end

      # @param user_id [Integer]
      # @param asset_id [Integer]
      #
      # @return [AdsManagement::Asset]
      # @raise [ActiveRecord::RecordNotFound]
      #
      def call(user_id:, asset_id:)
        user = User.find(user_id)
        asset = user.assets.find(asset_id)

        ActiveRecord::Base.transaction do
          asset.update!(active: false)
          notify_deactivated(asset)
        end
      end

      private

      attr_reader :_acme_integration

      # This is essentially the same as publishing an "AssetDeactivated" message
      # in event-based architecture, but in this showcase I avoid events for
      # simplicity and wider adoptability
      #
      def notify_deactivated(asset)
        case asset.source
        when 'acme'
          _acme_integration.deactivate_ad_account_sync(public_id: asset.public_id)
        end
      end
    end
  end
end
