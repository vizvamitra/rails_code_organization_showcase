module Api
  module MyIntegration
    class IdentityValiditySerializer < ApplicationSerializer
      attributes :success, :error_code

      def success
        object.success?
      end

      def error_code
        object.failure
      end

      private

      # Will remove error_code if it is empty
      #
      def attributes
        super.tap { |h| h.each { |k, v| h.delete(k) if v.nil? } }
      end
    end
  end
end
