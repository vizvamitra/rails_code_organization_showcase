module AcmeIntegration
  module Identities
    class ScheduleSync
      # @return [void]
      #
      def call
        syncable_identities.ids.each { |id| schedule_sync(id) }
      end

      private

      def syncable_identities
        Identity.with_valid_token
      end

      def schedule_sync(identity_id)
        AcmeIntegration::SyncIdentityJob.perform_later(identity_id)
      end
    end
  end
end
