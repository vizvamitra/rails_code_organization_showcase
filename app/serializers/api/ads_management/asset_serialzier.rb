# frozen_string_literal: true

module Api
  module AdsManagement
    class AssetSerializer < ApplicationSerializer
      attributes :id, :source, :name, :active
    end
  end
end
