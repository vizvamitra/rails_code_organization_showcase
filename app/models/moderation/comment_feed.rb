module Moderation
  class CommentFeed < ApplicationRecord
    belongs_to :client, inverse_of: :moderation_comment_feeds

    enum :platform, { acme: 0, meta: 1 }

    scope :not_moderated, -> { where(moderated: false) }
    scope :moderated, -> { where(moderated: true) }
    scope :connection_error, -> { moderated.where(connected: false) }

    def self.ransackable_attributes(auth_object = nil)
      %w[id public_id platform title created_at updated_at]
    end

    def self.ransackable_associations(auth_object = nil)
      %w[client]
    end

    def disconnected?
      !connected?
    end
  end
end
