module Moderation
  module Assets
    class ToggleModeration
      def initialize(acme_integration: AcmeIntegration::Interface.new)
        @_acme_integration = acme_integration
      end

      # @param client_id [Integer]
      # @param asset_id [Integer]
      # @param active [Boolean]
      #
      # @return [Moderation::Asset]
      # @raise [ActiveRecord::RecordNotFound]
      #
      def call(client_id:, asset_id:, active:)
        asset = Asset.where(client_id:).find(asset_id)
        return asset if asset.active == active

        raise AssetNotModeratableError if active && !asset.access_acquired?

        ApplicationRecord.transaction do
          asset.update!(active:)
          toggle_comment_retrieval(asset)
        end

        asset
      end

      private

      attr_reader :_acme_integration

      def toggle_comment_retrieval(asset)
        _acme_integration.toggle_page_comment_retrieval(
          public_id: asset.public_id,
          retrieve_comments: asset.active
        )
      end
    end
  end
end
