module Moderation
  class Asset < ApplicationRecord
    belongs_to :client, inverse_of: :moderation_assets

    enum :source, { acme: 0, meta: 1 }

    scope :paused, -> { where(active: false) }
    scope :active, -> { where(active: true) }
    scope :access_error, -> { active.where(access_acquired: false) }

    def self.ransackable_attributes(auth_object = nil)
      %w[id public_id source title created_at updated_at]
    end

    def self.ransackable_associations(auth_object = nil)
      %w[client]
    end
  end
end
