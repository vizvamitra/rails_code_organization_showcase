# frozen_string_literal: true

module AcmeIntegration
  class Ad < ApplicationRecord
    enum status: { active: 0, inactive: 2 }

    belongs_to :ad_account

    validates_presence_of :external_id, :name, :description, :status
  end
end
