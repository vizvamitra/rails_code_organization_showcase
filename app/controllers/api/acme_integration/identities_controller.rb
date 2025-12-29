module Api
  module AcmeIntegration
    class IdentitiesController < ApiController
      def create
        identity = Identities::Create.new.call(**create_params)
        render json: Alba.serialize(identity), status: :created
      end

      private

      def create_params
        {
          access_token: params.require(:identity).require(:access_token),
          client_id: Current.user.client_id
        }
      end
    end
  end
end
