# frozen_string_literal: true

module AcmeIntegration
  class AdAccount < ApplicationRecord
    enum access_status: { revoked: 0, acquired: 2, lost: 3 }, _prefix: :access
    enum status: { active: 0, paused: 1, archived: 2 }

    belongs_to :user
    has_many :ads

    validates_uniqueness_of :external_id, :public_id
  end
end
