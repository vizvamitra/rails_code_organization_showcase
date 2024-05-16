# frozen_string_literal: true

module AdsManagement
  class Interface < ::Subsystems::Interface
    logging_prefix 'AdsManagement'

    # @param user_id [Integer]
    # @param source [String]
    # @param public_id [Integer]
    # @param name [String]
    #
    # @return [AdsManagement::Asset]
    #
    def create_asset(**args)
      with_logging { Assets::Create.new.call(**args) }
    end
  end
end
