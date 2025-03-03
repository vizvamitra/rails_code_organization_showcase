module AcmeIntegration
  module Pages
    class UpdateAccessDetails
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

        # TODO: notify moderation about status change
      end

      private

      def status(discoverable, manager_role_granted)
        return :undiscoverable if !discoverable
        return :inoperable if !manager_role_granted

        :operable
      end
    end
  end
end
