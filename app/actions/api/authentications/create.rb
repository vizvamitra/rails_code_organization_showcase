module Api
  module Authentications
    class Create
      def call(email_address:, password:)
        user = User.authenticate_by(email_address:, password:)
        raise HttpErrors::NotFoundError if user.nil?

        user
      end
    end
  end
end
