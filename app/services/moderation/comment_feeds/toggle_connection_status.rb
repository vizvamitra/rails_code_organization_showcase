module Moderation
  module CommentFeeds
    class ToggleConnectionStatus
      # @param public_id [String]
      # @param connected [Boolean]
      #
      # @return [void]
      # @raise [ActiveRecord::RecordNotFound]
      #
      def call(public_id:, connected:)
        CommentFeed.find_by!(public_id:).update!(connected:)

        # Normally, there would probably be some other logics, like notifying
        # the user when his comment feed looses connection
      end
    end
  end
end
