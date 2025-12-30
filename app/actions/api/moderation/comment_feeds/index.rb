module Api
  module Moderation
    module CommentFeeds
      class Index
        def initialize(moderation: ::Moderation::Interface.new)
          @_moderation = moderation
        end

        def call(client_id:, **params)
          _moderation.list_comment_feeds(client_id:, **params)
        end

        private

        attr_reader :_moderation
      end
    end
  end
end
