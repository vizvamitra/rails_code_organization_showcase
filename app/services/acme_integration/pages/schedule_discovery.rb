module AcmeIntegration
  module Pages
    class ScheduleDiscovery
      # @return [void]
      #
      def call
        syncable_identities.ids.each { |id| schedule_discovery(id) }
      end

      private

      def syncable_identities
        Identity.with_valid_token.order(:client_id, :id)
      end

      def schedule_discovery(identity_id)
        AcmeIntegration::DiscoverPagesJob.perform_later(identity_id)
      end
    end
  end
end
