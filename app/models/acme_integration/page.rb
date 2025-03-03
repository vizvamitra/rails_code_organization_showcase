module AcmeIntegration
  class Page < ApplicationRecord
    belongs_to :client
    belongs_to :access_provider, class_name: "AcmeIntegration::Identity", optional: true

    # enum :access_status, { revoked: 0, partial: 1, granted: 2, degraded: 3 }, prefix: :access
    # enum :status, { undiscoverable: 0, not_moderatable: 1, moderatable: 2 }
    enum :status, { undiscoverable: 0, inoperable: 1, operable: 2 }
  end
end
