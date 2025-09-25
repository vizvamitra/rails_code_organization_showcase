module Moderation
  module Assets
    class ToggleAccessStatus
      # @param public_id [String]
      # @param access_acquired [Boolean]
      #
      # @return [void]
      # @raise [ActiveRecord::RecordNotFound]
      #
      def call(public_id:, access_acquired:)
        Asset.find_by!(public_id:).update!(access_acquired:)

        # Normally, there would probably be some other logics, like notifying
        # the user when his asset looses access
      end
    end
  end
end
