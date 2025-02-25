module AcmeIntegration
  class ScheduleIdentitiesSyncJob < ApplicationJob
    queue_as :default

    def perform
      Interface.new.schedule_identities_sync
    end
  end
end
