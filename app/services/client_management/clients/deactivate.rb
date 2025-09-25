module ClientManagement
  module Clients
    class Deactivate
      def initialize(moderation: Moderation::Interface.new)
        @moderation = moderation
      end

      # @param client_id [Integer]
      #
      # @return [Client]
      # @raise [ActiveRecord::RecordNotFound]
      #
      def call(client_id:)
        client = Client.find(client_id)

        ActiveRecord::Base.transaction do
          client.assets.each { |asset| deactivate_asset(client, asset) }
          client.update(status: :inactive)
        end
      end

      private

      attr_reader :moderation

      def deactivate_asset(client, asset)
        moderation.toggle_asset_moderation(
          client_id: client.id,
          asset_id: asset.id,
          moderated: false
        )
      end
    end
  end
end
