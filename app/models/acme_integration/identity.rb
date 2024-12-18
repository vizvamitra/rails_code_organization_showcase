module AcmeIntegration
  class Identity < ApplicationRecord
    belongs_to :client
    has_many :pages
  end
end
