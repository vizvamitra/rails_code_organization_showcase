module Api
  module Moderation
    module Assets
      module Activations
        class Destroy
          def initialize(moderation: ::Moderation::Interface.new)
            @_moderation = moderation
          end

          def call(client_id:, asset_id:)
            _moderation.toggle_asset_moderation(client_id:, asset_id:, active: false)
          end

          private

          attr_reader :_moderation
        end
      end
    end
  end
end
