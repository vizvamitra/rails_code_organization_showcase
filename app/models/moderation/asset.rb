module Moderation
  class Asset < ApplicationRecord
    belongs_to :client

    enum :source, { acme: 0, meta: 1 }

    scope :moderated, -> { where(moderated: true) }
    scope :moderated_first, -> { order(moderated: :asc) }

    def self.ransackable_attributes(auth_object = nil)
      %w[id public_id source title moderated access_acquired created_at updated_at]
    end

    def self.ransackable_associations(auth_object = nil)
      %w[client]
    end
  end
end
