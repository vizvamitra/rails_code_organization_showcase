class Client < ApplicationRecord
  has_many :users
  has_many :assets, class_name: "Moderation::Asset"
  has_many :acme_identities, class_name: "AcmeIntegration::Identity"
end
