module AcmeIntegration
  class Page < ApplicationRecord
    belongs_to :client
    belongs_to :identity

    # enum :access_status, { revoked: 0, limited: 1, granted: 2, degraded: 3 }, prefix: :access
    enum :status, { undiscoverable: 0, inoperable: 1, operable: 2, access_lost: 3 }
  end
end
