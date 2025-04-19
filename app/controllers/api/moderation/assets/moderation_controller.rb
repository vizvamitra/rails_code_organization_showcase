module Api
  module Moderation
    module Assets
      class ModerationController < ApiController
        def create
          asset = Assets::Moderation::Create.new.call(**create_params)

          render json: Alba.serialize(asset)
        end

        def destroy
          asset = Assets::Moderation::Destroy.new.call(**destroy_params)

          render json: Alba.serialize(asset)
        end

        private

        def create_params
          {
            client_id: Current.user.client_id,
            asset_id: params[:asset_id]
          }
        end

        def destroy_params
          create_params
        end
      end
    end
  end
end
