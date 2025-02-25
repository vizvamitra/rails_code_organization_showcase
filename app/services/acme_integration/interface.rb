module AcmeIntegration
  class Interface < Subsystems::Interface
    filtered_params %i[access_token]

    def create_identity(**params)
      with_logging { AcmeIntegration::Identities::Create.new.call(**params) }
    end

    def sync_identity(**params)
      with_logging { AcmeIntegration::Identities::Sync.new.call(**params) }
    end

    def schedule_identities_sync
      with_logging { AcmeIntegration::Identities::ScheduleSync.new.call }
    end
  end
end
