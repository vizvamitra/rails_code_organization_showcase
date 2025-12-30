module Api
  module Moderation
    class CommentFeedsController < ApiController
      def index
        feeds = CommentFeeds::Index.new.call(**index_params).then { paginate(_1) }

        render json: Alba.serialize(feeds, root_key: :data)
      end

      private

      def index_params
        {
          client_id: Current.user.client_id,
          **params.permit(:platform, :connected, :title, :order)
        }
      end
    end
  end
end
