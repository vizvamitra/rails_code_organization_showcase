module AcmeIntegration
  class Interface < Subsystems::Interface
    filtered_params %i[access_token]

    def create_identity(**params)
      with_logging { AcmeIntegration::Identities::Create.new.call(**params) }
    end

    def discover_pages(**params)
      with_logging { AcmeIntegration::Pages::Discover.new.call(**params) }
    end

    def schedule_pages_discovery
      with_logging { AcmeIntegration::Pages::ScheduleDiscovery.new.call }
    end

    def toggle_page_comment_retrieval(**params)
      with_logging { AcmeIntegration::Pages::ToggleCommentRetrieval.new.call(**params) }
    end
  end
end
