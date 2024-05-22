# frozen_string_literal: true

module AcmeIntegration
  class AdAccount < ApplicationRecord
    enum access_status: { acquired: 2, lost: 3 }, _prefix: :access

    belongs_to :user
    has_many :ads

    validates_uniqueness_of :external_id, :public_id
  end
end
