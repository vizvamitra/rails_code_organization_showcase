module Moderation
  class Interface < Subsystems::Interface
    def sync_asset(**params)
      with_logging { Moderation::Assets::Sync.new.call(**params) }
    end

    def toggle_asset_access_status(**params)
      with_logging { Moderation::Assets::ToggleAccessStatus.new.call(**params) }
    end

    def list_assets(**params)
      Moderation::Assets::List.new.call(**params)
    end
  end
end
