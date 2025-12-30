module Api
  module Moderation
    module CommentFeeds
      module Moderation
        class Create
          def initialize(moderation: ::Moderation::Interface.new)
            @_moderation = moderation
          end

          def call(client_id:, comment_feed_id:)
            _moderation.toggle_comment_feed_moderation(
              client_id:,
              comment_feed_id:,
              moderated: true
            )
          rescue ::Moderation::CommentFeedNotModeratableError
            raise HttpErrors::ConflictError
          end

          private

          attr_reader :_moderation
        end
      end
    end
  end
end
