require "rails_helper"

RSpec.describe AcmeIntegration::Pages::Actualize do
  subject(:actualize) do
    described_class
      .new(is_preferred_access_provider:, update_public_details:, update_access_details:)
      .call(identity:, attributes:)
  end

  let(:is_preferred_access_provider) do
    instance_spy(AcmeIntegration::Pages::IsPreferredAccessProvider)
  end
  let(:update_public_details) do
    instance_spy(AcmeIntegration::Pages::UpdatePublicDetails)
  end
  let(:update_access_details) do
    instance_spy(AcmeIntegration::Pages::UpdateAccessDetails)
  end

  let!(:client) { create(:client) }
  let!(:identity) { create(:acme_integration_identity, client:) }
  let!(:page) { create(:acme_integration_page, external_id: attributes.id, client:) }
  let(:attributes) do
    build(:acme_integration_page_attributes, manager_role_granted:)
  end

  let(:manager_role_granted) { true }
  let(:provider_preferred) { true }

  before do
    allow(is_preferred_access_provider).to receive(:call) { provider_preferred }
    allow(update_public_details).to receive(:call)
    allow(update_access_details).to receive(:call)
  end

  context "when page exists" do
    it "refreshes it's details and status" do
      expect { actualize }
        .to preserve { page.reload.public_id }
        .and change { page.reload.last_synced_at }.to be_within(1.second).of(Time.now)

      expect(actualize).to eq(page)

      expect(is_preferred_access_provider).to have_received(:call).with(
        page:,
        candidate: identity,
        operable_by_candidate: true
      )
      expect(update_public_details).to have_received(:call).with(
        page:,
        name: attributes.name,
        avatar_url: attributes.avatar_url,
      )
      expect(update_access_details).to have_received(:call).with(
        page:,
        access_provider: identity,
        discoverable: true,
        manager_role_granted:
      )
    end
  end

  context "when page doesn't yet exist" do
    let!(:page) { nil }

    it do
      expect { actualize }.to change(AcmeIntegration::Page, :count).by(1)
      expect(actualize).to be_a(AcmeIntegration::Page)
      expect(actualize).to have_attributes(
        last_synced_at: be_within(1.second).of(Time.now),
        public_id: be_a(String)
      )

      expect(is_preferred_access_provider).to have_received(:call).with(
        page: actualize,
        candidate: identity,
        operable_by_candidate: true
      )
      expect(update_public_details).to have_received(:call).with(
        page: actualize,
        name: attributes.name,
        avatar_url: attributes.avatar_url
      )
      expect(update_access_details).to have_received(:call).with(
        page: actualize,
        access_provider: identity,
        discoverable: true,
        manager_role_granted:
      )
    end
  end

  context "when identity is not a preferred provider" do
    let(:provider_preferred) { false }

    it "doesn't actulize the page" do
      expect { actualize }.not_to change { page.reload }

      expect(is_preferred_access_provider).to have_received(:call).with(
        page:,
        candidate: identity,
        operable_by_candidate: true
      )
      expect(update_public_details).not_to have_received(:call)
      expect(update_access_details).not_to have_received(:call)
    end
  end
end
