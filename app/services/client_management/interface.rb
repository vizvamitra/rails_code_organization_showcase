module ClientManagement
  class Interface < Subsystems::Interface
    def deactivate_client(**params)
      with_logging { ClientManagement::DeactivateClient.new.call(**params) }
    end
  end
end
