# frozen_string_literal: true

module AcmeIntegration
  module Identities
    class Attributes < Dry::Struct
      attribute :id, Types::String
      attribute :access_token, Types::String
      attribute :roles, Types::Array.of(Types::String)

      def admin?
        roles.include?('ADMIN')
      end
    end
  end
end
