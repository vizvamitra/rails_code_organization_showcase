# frozen_string_literal: true

module Subsystems
  # A wrapper over subsystem interfaces, providing common tooling around
  # interface calls (currently, only logging).
  #
  # Usage:
  #
  #   class ExampleInterface < Subsystems::Interface
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
  #   subsystem = ExampleInterface.new
  #
  #   subsystem.some_action(foo: 1, bar: 2)
  #   # => [Example#some_action {"foo":1,"bar":"[FILTERED]"}] started
  #   # => [Example#some_action {"foo":1,"bar":"[FILTERED]"}] finished in 1.01s seconds
  #
  #   subsystem.failing_action(foo: 1)
  #   # => [Example#failing_action {"foo":1}] started
  #   # => [Example#failing_action {"foo":1}] failed after 3ms with RuntimeError: I am doomed!
  #
  class Interface
    def initialize(logger: Rails.logger)
      @logger = logger
    end

    class << self
      def inherited(klass)
        klass.filtered_params([])
        klass.logging_prefix(klass.name.split("::").first.underscore)
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

      logger.tagged(tag(block, filtered)) do
        logger.info("started")

        begin
          result = block.call

          logger.info("finished in #{duration(start_time)}")
          result
        rescue StandardError => e
          logger.error("failed after #{duration(start_time)} with #{e.class}: #{e.message}")
          raise
        end
      end
    end

    def extract_params(method_name, binding)
      method(method_name)
        .parameters
        .flat_map do |type, name|
          value = binding.local_variable_get(name)
          type == :keyrest ? value.to_a : [ name, value ]
        end
        .to_h
        .with_indifferent_access
    end

    def tag(block, filtered_keys)
      method_name = block.binding.eval("__method__")
      params = extract_params(method_name, block.binding)
      filter(params, filtered_keys)

      "#{self.class.tag_prefix}##{method_name} #{params.to_json}"
    end

    def filter(params, filtered_keys)
      filtered_keys.each { |k| params[k] = "[FILTERED]" if params.key?(k) }
    end

    def current_time
      Process.clock_gettime(Process::CLOCK_MONOTONIC)
    end

    def duration(start_time)
      diff = (current_time - start_time)

      case diff
      when (...0.001) then "#{(diff * 1_000_000).round}ns" # less than a ms
      when (...1) then "#{(diff * 1000).round}ms"
      else "#{diff.round(2)}s"
      end
    end
  end
end
