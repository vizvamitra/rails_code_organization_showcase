module OffsetPagination
  PageInfo = Data.define(:prev, :current, :next, :total, :total_pages, :per_page)

  class PaginatedCollection
    include Enumerable

    attr_reader :page_info

    def initialize(items:, page_info:)
      @items = items
      @page_info = page_info
    end

    def each(&block)
      items.each(&block)
    end

    private

    attr_reader :items
  end

  class Paginate
    DEFAULT_PER_PAGE = 20

    def call(collection:, page:, per_page:)
      per_page ||= DEFAULT_PER_PAGE

      case collection
      when ActiveRecord::Relation
        paginate_ar_relation(collection, page:, per_page:)
      when Array
        paginate_emunerable(collection, page:, per_page:)
      else
        raise "Not a valid collection: #{collection.class}"
      end
    end

    private

    def paginate_ar_relation(relation, page:, per_page:)
      items = relation.offset((page - 1) * per_page).limit(per_page)
      total = relation.group_values.any? ? relation.count.values.sum : relation.count

      PaginatedCollection.new(items:, page_info: page_info(total, page, per_page))
    end

    def paginate_emunerable(collection, page:, per_page:)
      total = collection.count
      offset = (page - 1) * per_page
      items = collection.slice(offset, per_page) || []

      PaginatedCollection.new(items:, page_info: page_info(total, page, per_page))
    end

    def page_info(total, page, per_page)
      PageInfo.new(
        prev: page > 1 ? page - 1 : nil,
        current: page,
        next: page * per_page < total ? page + 1 : nil,
        total:,
        total_pages: (total.to_f / per_page).ceil,
        per_page:,
      )
    end
  end

  def paginate(collection:, page: 1, per_page: nil)
    Paginate.new.call(collection:, page:, per_page:)
  end
end
