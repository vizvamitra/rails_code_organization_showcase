module AcmeIntegration
  class DiscoverPagesJob < ApplicationJob
    queue_as :default

    def perform(identity_id)
      Interface.new.discover_pages(identity_id:)
    end
  end
end
