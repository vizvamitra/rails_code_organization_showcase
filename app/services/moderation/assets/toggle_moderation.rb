module Moderation
  module Assets
    class ToggleModeration
      def initialize(acme_integration: AcmeIntegration::Interface.new)
        @_acme_integration = acme_integration
      end

      # @param client_id [Integer]
      # @param asset_id [Integer]
      # @param moderated [Boolean]
      #
      # @return [Moderation::Asset]
      # @raise [ActiveRecord::RecordNotFound]
      #
      def call(client_id:, asset_id:, moderated:)
        asset = Asset.where(client_id:).find(asset_id)
        return asset if asset.moderated == moderated

        ApplicationRecord.transaction do
          asset.update!(moderated:)
          toggle_comment_retrieval(asset)
        end

        asset
      end

      private

      attr_reader :_acme_integration

      def toggle_comment_retrieval(asset)
        _acme_integration.toggle_page_comment_retrieval(
          public_id: asset.public_id,
          retrieve_comments: asset.moderated
        )
      end
    end
  end
end
