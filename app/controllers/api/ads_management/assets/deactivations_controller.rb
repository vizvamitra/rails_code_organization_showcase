# frozen_string_literal: true

module Api
  module AdsManagement
    module Assets
      class DeactivationsController < ApiController
        # POST /ads_management/assets/:id/deactivations
        #
        def create
          result = AdsManagement::Assets::Deactivations::Create.new.call(**create_params)
          render json: result, serializer: AssetSerializer
        end

        private

        def create_params
          {
            asset_id: params[:asset_id],
            user_id: current_user.id
          }
        end
      end
    end
  end
end
