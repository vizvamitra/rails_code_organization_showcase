require "rails_helper"

RSpec.describe AcmeIntegration::Pages::Discover do
  subject(:discover) do
    described_class
      .new(sync_identity:, fetch_all:, actualize:, update_access_details:)
      .call(identity_id:)
  end

  let(:sync_identity) { instance_spy(AcmeIntegration::Identities::Sync) }
  let(:fetch_all) { instance_spy(AcmeIntegration::Pages::FetchAll) }
  let(:actualize) { instance_spy(AcmeIntegration::Pages::Actualize) }
  let(:update_access_details) do
    instance_spy(AcmeIntegration::Pages::UpdateAccessDetails)
  end

  let!(:client) { create(:client) }
  let!(:identity) do
    create(
      :acme_integration_identity,
      can_discover_pages ? :full_access : :revoked_access,
      client:,
      access_token: "whatever"
    )
  end
  let!(:pages) do
    [
      create(:acme_integration_page, client:, access_provider: identity),
      create(:acme_integration_page, client:, access_provider: identity),
      create(:acme_integration_page)
    ]
  end
  let(:pages_attributes) do
    [
      build(:acme_integration_page_attributes, id: pages[0].external_id), # existing
      build(:acme_integration_page_attributes) # new
    ]
  end

  let(:identity_id) { identity.id }
  let(:can_discover_pages) { true }
  let(:syncing_error) { nil }
  let(:fetching_error) { nil }

  before do
    allow(sync_identity).to receive(:call) do
      syncing_error ? raise(syncing_error) : identity
    end
    allow(fetch_all).to receive(:call) do
      fetching_error ? raise(fetching_error) : pages_attributes
    end
    allow(actualize).to receive(:call).at_most(2).times
    allow(update_access_details).to receive(:call)
  end

  it "syncs identity, syncs pages, cleans up providers for undiscoverable" do
    discover

    expect(sync_identity).to have_received(:call).with(identity:)
    expect(fetch_all).to have_received(:call).with(access_token: "whatever")

    pages_attributes.each do |attributes|
      expect(actualize).to have_received(:call).with(identity:, attributes:)
    end

    expect(update_access_details).to have_received(:call).with(
      page: pages[1],
      access_provider: nil,
      discoverable: false,
      manager_role_granted: false
    )
  end

  context "when identity looses ability to discover pages after sync" do
    let(:can_discover_pages) { false }

    it "cleans up providers for all pages provided by given identity" do
      discover

      expect(sync_identity).to have_received(:call).with(identity:)
      expect(fetch_all).not_to have_received(:call)
      expect(actualize).not_to have_received(:call)

      pages[0..1].each do |page|
        expect(update_access_details).to have_received(:call).with(
          page:,
          access_provider: nil,
          discoverable: false,
          manager_role_granted: false
        )
      end
    end
  end

  context "when identity can't be found" do
    let(:identity_id) { "invalid" }
    it { expect { discover }.to raise_error(ActiveRecord::RecordNotFound) }
  end

  context "when identity sync fails" do
    let(:syncing_error) { Acme::Error }
    it { expect { discover }.to raise_error(syncing_error) }
  end

  context "when pages fetch fails" do
    let(:fetching_error) { AcmeIntegration::AccessTokenInvalidError }
    it { expect { discover }.to raise_error(fetching_error) }
  end
end
