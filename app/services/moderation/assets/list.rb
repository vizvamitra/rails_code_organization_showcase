module Moderation
  module Assets
    class List
      ORDER_FIELDS = %w[source title active access_acquired]
      DEFAULT_ORDER = { title: :asc }

      # @param client_id [Integer]
      # @param source [String, nil]
      # @param title [String, nil]
      # @param access_acquired [Boolean, nil]
      # @param order [String, nil]
      #
      # @return [ActiveRecord::Relation]
      # @raise [ActiveRecord::RecordNotFound]
      #
      def call(client_id:, source: nil, title: nil, access_acquired: nil, order: nil)
        client = Client.find(client_id)

        client
          .moderation_assets
          .then { |scope| filter_by_source(scope, source) }
          .then { |scope| filter_by_title(scope, title) }
          .then { |scope| filter_by_access_status(scope, access_acquired) }
          .then { |scope| apply_ordering(scope, order) }
      end

      private

      def filter_by_source(scope, source)
        source.nil? ? scope : scope.where(source:)
      end

      def filter_by_title(scope, title)
        title.nil? ? scope : scope.where("LOWER(title) LIKE ?", "%#{title.downcase}%")
      end

      def filter_by_access_status(scope, access_acquired)
        access_acquired.nil? ? scope : scope.where(access_acquired:)
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
