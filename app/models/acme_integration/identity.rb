module AcmeIntegration
  class Identity < ApplicationRecord
    belongs_to :client
    has_many :pages

    enum :access_status, { revoked: 0, partial: 1, full: 2, degraded: 3 }, prefix: :access

    scope :with_valid_token, -> { where(access_token_valid: true) }
  end
end
