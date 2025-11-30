module AcmeIntegration
  module Pages
    class UpdatePublicDetails
      def initialize(moderation: Moderation::Interface.new)
        @_moderation = moderation
      end

      # @param page [AcmeIntegration::Page]
      # @param name [String]
      # @param avatar_url [String]
      #
      # @return [void]
      #
      def call(page:, name:, avatar_url:)
        page.update!(name:, avatar_url:)
        notify_moderation(page)
      end

      private

      attr_reader :_moderation

      def notify_moderation(page)
        _moderation.sync_asset(
          client_id: page.client_id,
          source: :acme,
          public_id: page.public_id,
          external_id: page.external_id,
          title: page.name,
          url: page.url,
          avatar_url: page.avatar_url
        )
      end
    end
  end
end
