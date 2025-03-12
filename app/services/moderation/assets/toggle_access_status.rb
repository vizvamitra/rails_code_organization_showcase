module Moderation
  module Assets
    class ToggleAccessStatus
      # @param public_id [String]
      # @param access_acquired [Bool]
      #
      # @return [void]
      # @raise [ActiveRecord::RecordNotFound]
      #
      def call(public_id:, access_acquired:)
        Asset.find_by!(public_id:).update!(access_acquired:)
      end
    end
  end
end
