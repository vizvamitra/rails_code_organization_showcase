module AcmeIntegration
  class PageSerializer < ApplicationSerializer
    attributes :id, :public_id, :client_id, :facebook_id, :name, :avatar_url,
               :status, :discoverable, :manager_role_granted
  end
end
