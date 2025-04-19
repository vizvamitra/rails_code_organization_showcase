module Moderation
  class AssetSerializer < ApplicationSerializer
    attributes :id, :client_id, :source, :title, :url, :avatar_url, :moderated,
               :access_acquired
  end
end
