module AcmeIntegration
  class IdentitySerializer < ApplicationSerializer
    attributes :id, :client_id, :external_id, :name, :avatar_url, :access_status,
               :access_token_valid, :can_discover_pages, :can_moderate_comments
  end
end
