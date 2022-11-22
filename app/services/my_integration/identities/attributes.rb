module MyIntegration
  module Identities
    class Attributes < Dry::Struct
      attribute :id, Types::String
      attribute :name, Types::String
      attribute :avatar_url, Types::String
      attribute :access_token, Types::String
      attribute :roles, Types::Array.of(Types::String)
      
      def admin?
        roles.include?('ADMIN')
      end
    end
  end
end
