module Moderation
  module Assets
    class Sync
      # @param client_id [Integer]
      # @param source [Symbol]
      # @param public_id [String]
      # @param attributes [Hash]
      # @option attributes [String] :title
      # @option attributes [String] :url
      # @option attributes [String] :avatar_url
      #
      # @return [void]
      # @raise [ActiveRecord::RecordNotFound]
      # @raise [NoMatchingPatternError]
      #
      def call(client_id:, source:, public_id:, **attributes)
        client = Client.find(client_id)
        asset = find_or_build(client, source, public_id)

        attributes => { title:, url:, avatar_url: }
        asset.update!(title:, url:, avatar_url:)
      end

      private

      def find_or_build(client, source, public_id)
        client.assets.find_or_initialize_by(source:, public_id:)
      end
    end
  end
end
