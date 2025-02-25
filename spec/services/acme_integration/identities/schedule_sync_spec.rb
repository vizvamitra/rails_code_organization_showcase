require "rails_helper"

RSpec.describe AcmeIntegration::Identities::ScheduleSync do
  subject(:schedule_sync) { described_class.new.call }

  let!(:identities) do
    [
      create(:acme_integration_identity, access_token_valid: true),
      create(:acme_integration_identity, access_token_valid: true),
      create(:acme_integration_identity, access_token_valid: false)
    ]
  end

  it "schedules syncs for identities with valid token" do
    expect { schedule_sync }
      .to have_enqueued_job(AcmeIntegration::SyncIdentityJob).with(identities[0].id)
      .and have_enqueued_job(AcmeIntegration::SyncIdentityJob).with(identities[1].id)
  end
end
