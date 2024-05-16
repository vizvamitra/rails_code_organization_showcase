# frozen_string_literal: true

module AcmeIntegration
  class ScheduleAdsSyncJob
    include Sidekiq::Job

    def perform
      acme_integration.schedule_ads_sync
    end

    private

    def acme_integration
      ::AcmeIntegration::Interface.new
    end
  end
end
