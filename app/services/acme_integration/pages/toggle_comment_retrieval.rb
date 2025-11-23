module AcmeIntegration
  module Pages
    class ToggleCommentRetrieval
      # @param public_id [UUID]
      # @param retrieve_comments [Boolean]
      #
      # @return [void]
      # @raise [ActiveRecord::RecordNotFound]
      #
      def call(public_id:, retrieve_comments:)
        page = Page.find_by!(public_id:)

        # Depending on the social network, you may need to perform some additional
        # actions here. Say, for a Facebook page you'll need to subscribe for
        # page's webhooks

        page.update!(retrieve_comments:)
      end
    end
  end
end
