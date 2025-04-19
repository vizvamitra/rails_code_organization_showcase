module Api
  module Pagination
    extend ActiveSupport::Concern

    DEFAULT_PAGE_SIZE = 20
    MAX_PAGE_SIZE = 100

    included do
      private

      def paginate(collection)
        page = params.permit(page: %i[number size])[:page]

        page_number = page ? page.require(:number).to_i : nil
        page_size = page ? page[:size]&.to_i : nil

        paginate = OffsetPagination::Paginate.new(
          default_page_size: DEFAULT_PAGE_SIZE,
          max_page_size: MAX_PAGE_SIZE
        )

        paginate.call(collection:, page_number:, page_size:)
      end
    end
  end
end
