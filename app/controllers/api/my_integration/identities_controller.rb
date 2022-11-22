module Api
  module MyIntegration
    class IdentitiesController < ApiController

      # ...

      # GET /my_integration/identities/validate
      #
      def validate
        result = ::Api::MyIntegration::Identities::Validate.new.call(
          account_id: current_user.account_id,
          **validate_params
        )

        render json: result, serializer: MyIntegration::IdentityValiditySerializer
      end

      private

      def validate_params
        params.require(:identity).permit(:external_id, :access_token)
      end
    end
  end
end
