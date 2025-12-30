module Api
  module Moderation
    module CommentFeeds
      class ModerationController < ApiController
        def create
          feed = CommentFeeds::Moderation::Create.new.call(**create_params)

          render json: Alba.serialize(feed)
        end

        def destroy
          feed = CommentFeeds::Moderation::Destroy.new.call(**destroy_params)

          render json: Alba.serialize(feed)
        end

        private

        def create_params
          {
            client_id: Current.user.client_id,
            comment_feed_id: params[:comment_feed_id]
          }
        end

        def destroy_params
          create_params
        end
      end
    end
  end
end
