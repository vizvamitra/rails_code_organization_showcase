# frozen_string_literal: true

module Api
  module AdsManagement
    module Assets
      module Deactivations
        class Create
          def initialize(ads_management: ::AdsManagement::Interface.new)
            @_ads_management = ads_management
          end

          # @param user_id [Integer]
          # @param asset_id [Integer]
          #
          # @return [AdsManagement::Asset]
          #
          # @raise [ActiveRecord::RecordNotFound]
          #
          def call(user_id, asset_id)
            deactivate_asset(user_id, asset_id)
          end

          private

          attr_reader :_ads_management

          def deactivate_asset(user_id, asset_id)
            _ads_management.deactivate_asset(user_id:, asset_id:)
          end
        end
      end
    end
  end
end
