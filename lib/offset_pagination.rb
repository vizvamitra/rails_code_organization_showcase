module OffsetPagination
  class Paginate
    def initialize(default_page_size: 20, max_page_size: 100)
      @default_page_size = default_page_size
      @max_page_size = max_page_size
    end

    # @param collection [ActiveRecord::Relation,Array]
    # @param page_number [Integer, nil]
    # @param page_size [Integer, nil]
    #
    # @return [ActiveRecord::Relation,Kaminari::PaginatableArray]
    #
    def call(collection:, page_number:, page_size:)
      number = normalize_page_number(page_number)
      size = normalize_page_size(page_size)

      paginate(collection).page(number).per(size)
    end

    private

    attr_reader :default_page_size, :max_page_size

    def normalize_page_number(number)
      return 1 if number.nil?

      [number, 1].max
    end

    def normalize_page_size(size)
      return default_page_size if size.nil?

      [[size, 1].max, max_page_size].min
    end

    def paginate(collection)
      case collection
      when ActiveRecord::Relation then collection
      when Array then Kaminari.paginate_array(collection)
      end
    end
  end
end
