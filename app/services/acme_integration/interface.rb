module AcmeIntegration
  class Interface < Subsystems::Interface
    filtered_params %i[access_token]

    def create_identity(**params)
      with_logging { AcmeIntegration::Identities::Create.new.call(**params) }
    end
  end
end
