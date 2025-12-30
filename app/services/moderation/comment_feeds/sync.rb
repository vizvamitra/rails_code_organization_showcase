module Moderation
  module CommentFeeds
    class Sync
      # @param client_id [Integer]
      # @param platform [Symbol]
      # @param public_id [String]
      # @param upstream_id [String]
      # @param attributes [Hash]
      # @option attributes [String] :title
      # @option attributes [String] :url
      # @option attributes [String] :avatar_url
      #
      # @return [void]
      # @raise [ActiveRecord::RecordNotFound]
      # @raise [NoMatchingPatternError]
      #
      def call(client_id:, platform:, public_id:, upstream_id:, **attributes)
        client = Client.find(client_id)
        feed = find_or_build(client, platform, public_id, upstream_id)

        attributes => { title:, url:, avatar_url: }
        feed.update!(title:, url:, avatar_url:)
      end

      private

      def find_or_build(client, platform, public_id, upstream_id)
        client
          .moderation_comment_feeds
          .create_with(upstream_id:)
          .find_or_initialize_by(platform:, public_id:)
      end
    end
  end
end
