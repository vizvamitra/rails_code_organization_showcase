module Moderation
  class CommentFeedSerializer < ApplicationSerializer
    attributes :id, :client_id, :platform, :public_id, :title, :url, :avatar_url,
               :moderated, :connected
  end
end
