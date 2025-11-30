module Api
  module Moderation
    module Assets
      module Activations
        class Create
          def initialize(moderation: ::Moderation::Interface.new)
            @_moderation = moderation
          end

          def call(client_id:, asset_id:)
            _moderation.toggle_asset_moderation(client_id:, asset_id:, active: true)
          rescue ::Moderation::AssetNotModeratableError
            raise HttpErrors::ConflictError
          end

          private

          attr_reader :_moderation
        end
      end
    end
  end
end
