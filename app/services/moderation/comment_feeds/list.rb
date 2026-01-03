module Moderation
  module CommentFeeds
    class List
      ORDER_FIELDS = %w[platform title moderated connected]
      DEFAULT_ORDER = { title: :asc }

      # @param client_id [Integer]
      # @param platform [String, nil]
      # @param title [String, nil]
      # @param connected [Boolean, nil]
      # @param order [String, nil]
      #
      # @return [ActiveRecord::Relation]
      # @raise [ActiveRecord::RecordNotFound]
      #
      def call(client_id:, platform: nil, title: nil, connected: nil, order: nil)
        client = Client.find(client_id)

        client
          .moderation_comment_feeds
          .then { |scope| filter_by_platform(scope, platform) }
          .then { |scope| filter_by_title(scope, title) }
          .then { |scope| filter_by_connection_status(scope, connected) }
          .then { |scope| apply_ordering(scope, order) }
      end

      private

      def filter_by_platform(scope, platform)
        platform.nil? ? scope : scope.where(platform:)
      end

      def filter_by_title(scope, title)
        return scope if title.nil?

        title = CommentFeed.sanitize_sql_like(title)
        scope.where("LOWER(title) LIKE ?", "%#{title.downcase}%")
      end

      def filter_by_connection_status(scope, connected)
        connected.nil? ? scope : scope.where(connected:)
      end

      def apply_ordering(scope, order)
        return scope.order(DEFAULT_ORDER) if order.blank?

        direction = order.start_with?("-") ? :desc : :asc
        field = order.delete_prefix("-")

        ordering = ORDER_FIELDS.include?(field) ? { field => direction } : DEFAULT_ORDER
        scope.order(ordering)
      end
    end
  end
end
