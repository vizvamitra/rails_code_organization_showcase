module AcmeIntegration
  module Identities
    class RefreshStatus
      # @param identity [AcmeIntegration::Identity]
      #
      # @return [void]
      #
      def call(identity:)
        identity.update!(
          access_token_valid: access_token_valid?(identity),
          can_discover_pages: can_discover_pages?(identity),
          can_moderate_comments: can_moderate_comments?(identity),
          access_status: status(identity)
        )
      end

      private

      def access_token_valid?(identity)
        identity.access_token.present?
      end

      def can_discover_pages?(identity)
        return false unless access_token_valid?(identity)

        identity.permission_public_profile_read? && identity.permission_pages_read?
      end

      def can_moderate_comments?(identity)
        return false unless can_discover_pages?(identity)

        identity.permission_page_comments_read? &&
          identity.permission_page_comments_manage?
      end

      def status(identity)
        if !access_token_valid?(identity)
          :revoked
        elsif !can_moderate_comments?(identity)
          :partial
        else
          :full
        end
      end
    end
  end
end
