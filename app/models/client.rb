class Client < ApplicationRecord
  has_many :users
  has_many :assets, class_name: "Moderation::Asset"
end
