module Api
  module Moderation
    class AssetsController < ApiController
      def index
        assets = Assets::Index.new.call(**index_params).then { paginate(_1) }

        # `Alba.serialize(collection)` ignores root_key
        # Bug ticket: https://github.com/okuramasafumi/alba/issues/426
        #
        render json: ::Moderation::AssetSerializer.new(assets).serialize
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
