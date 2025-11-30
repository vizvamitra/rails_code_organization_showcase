module Moderation
  class AssetSerializer < ApplicationSerializer
    attributes :id, :client_id, :source, :title, :url, :avatar_url, :active,
               :access_acquired
  end
end
