module Api
  module Moderation
    class AssetsController < ApiController
      def index
        assets = Assets::Index.new.call(**index_params).then { paginate(_1) }

        render json: Alba.serialize(assets, root_key: "data")
      end

      private

      def index_params
        {
          client_id: Current.user.client_id,
          **params.permit(:source, :access_acquired, :order)
        }
      end
    end
  end
end
