module AcmeIntegration
  class SyncIdentityJob < ApplicationJob
    queue_as :default

    def perform(identity_id)
      Interface.new.sync_identity(identity_id:)
    end
  end
end
