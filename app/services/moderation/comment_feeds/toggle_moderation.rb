module Moderation
  module CommentFeeds
    class ToggleModeration
      def initialize(acme_integration: AcmeIntegration::Interface.new)
        @_acme_integration = acme_integration
      end

      # @param client_id [Integer]
      # @param comment_feed_id [Integer]
      # @param moderated [Boolean]
      #
      # @return [Moderation::CommentFeed]
      # @raise [ActiveRecord::RecordNotFound]
      #
      def call(client_id:, comment_feed_id:, moderated:)
        feed = CommentFeed.where(client_id:).find(comment_feed_id)
        return feed if feed.moderated == moderated

        raise CommentFeedNotModeratableError if moderated && !feed.connected?

        ApplicationRecord.transaction do
          feed.update!(moderated:)
          toggle_comment_retrieval(feed)
        end

        feed
      end

      private

      attr_reader :_acme_integration

      def toggle_comment_retrieval(feed)
        _acme_integration.toggle_page_comment_retrieval(
          public_id: feed.public_id,
          retrieve_comments: feed.moderated
        )
      end
    end
  end
end
