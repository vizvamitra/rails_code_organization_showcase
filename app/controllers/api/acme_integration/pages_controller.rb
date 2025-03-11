module Api
  module AcmeIntegration
    class PagesController < ApiController
      def index
        pages = ::AcmeIntegration::Page
          .where(client_id: Current.user.client_id)
          .order(name: :asc)

        # `Alba.serialize(collection)` ignores root_key
        # Bug ticket: https://github.com/okuramasafumi/alba/issues/426
        #
        render json: ::AcmeIntegration::PageSerializer.new(pages).serialize
      end
    end
  end
end
