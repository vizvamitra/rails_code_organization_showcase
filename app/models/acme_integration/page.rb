module AcmeIntegration
  class Page < ApplicationRecord
    belongs_to :client
    belongs_to :access_provider, class_name: "AcmeIntegration::Identity", optional: true

    # Alternative namings:
    # - access_status: revoked / partial / granted / degraded
    # -        status: undiscoverable / not_moderatable / moderatable
    #
    enum :status, { undiscoverable: 0, inoperable: 1, operable: 2 }

    validates :external_id, presence: true, uniqueness: { scope: :client_id }

    def url
      "https://www.example.com/page/#{external_id}"
    end
  end
end
