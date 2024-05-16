# frozen_string_literal: true

module Api
  module AcmeIntegration
    class AdAccountSerializer < ApplicationSerializer
      attributes :id, :name, :avatar_url, :admin

      def admin
        object.admin?
      end
    end
  end
end
