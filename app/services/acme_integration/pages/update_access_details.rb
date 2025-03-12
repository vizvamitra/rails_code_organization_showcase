module AcmeIntegration
  module Pages
    class UpdateAccessDetails
      def initialize(moderation: Moderation::Interface.new)
        @_moderation = moderation
      end

      # @param page [AcmeIntegration::Page]
      # @param access_provider [AcmeIntegration::Identity]
      # @param discoverable [Boolean]
      # @param manager_role_granted [Boolean]
      #
      # @return [void]
      #
      def call(page:, access_provider:, discoverable:, manager_role_granted:)
        page.update!(
          access_provider:,
          discoverable:,
          manager_role_granted:,
          status: status(discoverable, manager_role_granted)
        )

        notify_moderation(page)
      end

      private

      attr_reader :_moderation

      def status(discoverable, manager_role_granted)
        return :undiscoverable if !discoverable
        return :inoperable if !manager_role_granted

        :operable
      end

      def notify_moderation(page)
        _moderation.toggle_asset_access_status(
          public_id: page.public_id,
          access_acquired: page.operable?
        )
      end
    end
  end
end
