module AcmeIntegration
  class SchedulePagesDiscoveryJob < ApplicationJob
    queue_as :default

    def perform
      Interface.new.schedule_pages_discovery
    end
  end
end
