module AcmeIntegration
  module Pages
    class IsPreferredAccessProvider
      # @param page [AcmeIntegration::Page]
      # @param candidate [AcmeIntegration::Identity]
      # @param operable_by_candidate [Boolean]
      #
      # @return [Boolean]
      #
      def call(page:, candidate:, operable_by_candidate:)
        return true if no_provider?(page)
        return true if same_provider?(page, candidate)
        return true if higher_access?(page, operable_by_candidate)

        false
      end

      private

      def no_provider?(page)
        page.access_provider.nil?
      end

      def same_provider?(page, candidate)
        page.access_provider == candidate
      end

      def higher_access?(page, operable_by_candidate)
        operable_by_candidate && !page.operable?
      end
    end
  end
end
