module Api
  module TokenAuthentication
    extend ActiveSupport::Concern

    included do
      before_action :require_token_authentication
    end

    class_methods do
      def allow_unauthenticated_api_calls(**options)
        skip_before_action :require_token_authentication, **options
      end
    end

    private

    # It is obviously insecure to handle token authn like this, so don't copy
    # this to your apps please. I just didn't want to spend too much time on
    # setting up authentication in this repo, cause it is not essential here
    #
    def require_token_authentication
      if user = authenticate_with_http_token { |t, o| User.find_by(access_token: t) }
        Current.session = Session.new(user:)
      else
        raise HttpErrors::UnauthorizedError
      end
    end
  end
end
