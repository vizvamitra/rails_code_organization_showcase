# frozen_string_literal: true

# A standard devise user model
#
class User < ApplicationRecord
  has_many :acme_ad_accounts, class_name: 'AcmeIntegration::AdAccount'
  has_many :assets, class_name: 'AdsManagement::Asset'
end
