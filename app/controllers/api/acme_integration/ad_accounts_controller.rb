# frozen_string_literal: true

module Api
  module AcmeIntegration
    class AdAccountsController < ApiController
      # POST /acme_integration/ad_accounts
      #
      def create
        result = AdAccounts::Create.new.call(**create_params)
        render json: result, serializer: AdAccountSerializer
      end

      private

      def create_params
        {
          access_token: params.require(:ad_account).require(:access_token),
          user_id: current_user.id
        }
      end
    end
  end
end
