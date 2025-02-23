class UserSerializer < ApplicationSerializer
  attributes :id, :client_id, :email_address, :access_token
end
