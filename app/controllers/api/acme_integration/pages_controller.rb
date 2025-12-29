module Api
  module AcmeIntegration
    class PagesController < ApiController
      def index
        pages = ::AcmeIntegration::Page
          .where(client_id: Current.user.client_id)
          .order(name: :asc)
          .then { paginate(_1) }

        render json: Alba.serialize(pages, root_key: :data)
      end
    end
  end
end
