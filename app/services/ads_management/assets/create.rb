# frozen_string_literal: true

module AdsManagement
  module Assets
    class Create
      # @param user_id [Integer]
      # @param source [String]
      # @param public_id [Integer]
      # @param name [String]
      #
      # @return [AdsManagement::Asset]
      # @raise [ActiveRecord::RecordNotFound]
      #
      def call(user_id:, source:, public_id:, name:)
        user = User.find(user_id)

        user.assets.create!(source:, public_id:, name:, access_acquired: true)
      end
    end
  end
end
