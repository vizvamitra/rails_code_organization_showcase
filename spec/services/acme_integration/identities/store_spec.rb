require "rails_helper"

RSpec.describe AcmeIntegration::Identities::Store do
  subject(:store) do
    described_class.new(refresh_status:).call(client:, attributes:)
  end

  let(:refresh_status) { instance_spy(AcmeIntegration::Identities::RefreshStatus) }

  let!(:client) { create(:client) }
  let(:attributes) { build(:acme_integration_identity_attributes) }

  before do
    allow(refresh_status)
      .to receive(:call).with(identity: be_a(AcmeIntegration::Identity))
  end

  context "when storing a new identity" do
    it "creates new identity, refreshes it's status" do
      expect { store }.to change(AcmeIntegration::Identity, :count).by(1)

      expect(refresh_status)
        .to have_received(:call).with(identity: be_a(AcmeIntegration::Identity))

      expect(store).to be_a(AcmeIntegration::Identity)
      expect(store).to have_attributes(
        acme_id: attributes.id,
        client:,
        **attributes.to_h.except(:id)
      )
    end
  end

  context "when storing an existing identity" do
    let!(:identity) do
      create(
        :acme_integration_identity,
        :revoked_access,
        client:,
        acme_id: attributes.id,
        name: "Jane Doe",
        avatar_url: "https://example.com/whatever.png"
      )
    end

    it "creates updates existing identity, refreshes it's status" do
      expect { store }.not_to change(AcmeIntegration::Identity, :count)

      expect(refresh_status).to have_received(:call).with(identity:)

      expect(store).to eq(identity)
      expect(identity.reload).to have_attributes(
        acme_id: attributes.id,
        client:,
        **attributes.to_h.except(:id)
      )
    end
  end
end
