# Common logics for public domain interfaces. Only logging for now.
#
# Usage:
#
#   class ExampleInterface < DomainInterface
#     logging_prefix 'Example'
#     filtered_params %i[bar]
#
#     def some_action(**args)
#       with_logging { sleep 1 }
#     end
#
#     def failing_action(**args)
#       with_logging { raise 'I am doomed!' }
#     end
#   end
#
#   service = ExampleInterface.new
#
#   service.some_action(foo: 1, bar: 2)
#   # => ... [Example#some_action {"foo":1,"bar":"[FILTERED]"}] started
#   # => ... [Example#some_action {"foo":1,"bar":"[FILTERED]"}] finished in 1.002758 seconds
#
#   service.failing_action(foo: 1)
#   # => ... [Example#failing_action {"foo":1}] started
#   # => ... [Example#failing_action {"foo":1}] failed after 0.00094 seconds -- {:error=>"I am doomed!"}
#
class DomainInterface
  def initialize(logger: Rails.logger)
    @logger = logger
  end

  class << self
    def inherited(klass)
      klass.filtered_params([])
      klass.logging_prefix(klass.name.split('::').first.underscore)
      super
    end

    def filtered_params(names)
      @filtered_by_default = names
    end

    def logging_prefix(prefix)
      @tag_prefix = prefix
    end

    attr_reader :filtered_by_default, :tag_prefix
  end

  private

  attr_reader :logger

  def with_logging(filtered: [], &block)
    filtered += self.class.filtered_by_default
    start_time = current_time

    logger.with_tags(tag(block, filtered)) do
      logger.info('started')

      begin
        result = block.call

        logger.info("finished in #{duration(start_time)} seconds")
        result
      rescue StandardError => e
        logger.error("failed after #{duration(start_time)} seconds", error: e.message)
        raise
      end
    end
  end

  # ...
end
