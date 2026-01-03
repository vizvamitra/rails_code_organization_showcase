module AcmeIntegration
  class Identity < ApplicationRecord
    belongs_to :client
    has_many :pages, inverse_of: :access_provider

    enum :access_status, { revoked: 0, partial: 1, full: 2 }, prefix: :access

    scope :with_valid_token, -> { where(access_token_valid: true) }
  end
end
