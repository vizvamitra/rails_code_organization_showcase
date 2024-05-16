# frozen_string_literal: true

module AdsManagement
  class Asset < ApplicationRecord
    enum source: { acme: 0 }

    belongs_to :user

    validates_uniqueness_of :public_id
  end
end
