require "rails_helper"

RSpec.describe AcmeIntegration::Pages::ScheduleDiscovery do
  subject(:schedule) { described_class.new.call }

  let!(:identities) do
    [
      create(:acme_integration_identity, access_token_valid: true),
      create(:acme_integration_identity, access_token_valid: true),
      create(:acme_integration_identity, access_token_valid: false)
    ]
  end

  it "schedules syncs for identities with valid token" do
    expect { schedule }
      .to have_enqueued_job(AcmeIntegration::DiscoverPagesJob).with(identities[0].id)
      .and have_enqueued_job(AcmeIntegration::DiscoverPagesJob).with(identities[1].id)
  end
end
