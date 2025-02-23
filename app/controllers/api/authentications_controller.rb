module Api
  class AuthenticationsController < ApiController
    allow_unauthenticated_api_calls only: %i[create]

    rate_limit to: 5, within: 3.minutes, only: :create, with: (lambda do
      raise HttpErrors::TooManyRequestsError.new(nil, 3.minutes.to_i)
    end)

    def create
      user = Authentications::Create.new.call(**create_params)

      render json: Alba.serialize(user)
    end

    private

    def create_params
      user = params.require(:user)

      {
        email_address: user.require(:email_address),
        password: user.require(:password)
      }
    end
  end
end
