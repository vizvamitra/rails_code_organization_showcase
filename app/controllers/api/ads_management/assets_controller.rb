# frozen_string_literal: true

module Api
  module AdsManagement
    class AssetsController < ApiController
      # GET /ads_management/assets
      #
      def index
        assets = current_user.assets.order(:source, :name)
        render json: assets, each_serializer: AssetSerializer
      end
    end
  end
end
