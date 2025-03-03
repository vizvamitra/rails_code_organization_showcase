module AcmeIntegration
  module Pages
    class UpdatePublicDetails
      # @param page [AcmeIntegration::Page]
      # @param name [String]
      # @param avatar_url [String]
      #
      # @return [void]
      #
      def call(page:, name:, avatar_url:)
        page.update!(name:, avatar_url:)
        # TODO: notify moderation once implemented
      end
    end
  end
end
