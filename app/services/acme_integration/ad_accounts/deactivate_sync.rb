# frozen_string_literal: true

module AcmeIntegration
  module AdAccounts
    class DeactivateSync
      # @param public_id [String]
      #
      # @return [Void]
      # @raise [ActiveRecord::RecordNotFound]
      #
      def call(public_id:)
        AdAccount.find_by!(public_id:).update!(ads_syncronization: false)
      end
    end
  end
end
