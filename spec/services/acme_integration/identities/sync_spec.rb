require "rails_helper"

RSpec.describe AcmeIntegration::Identities::Sync do
  subject(:sync) do
    described_class.new(fetch_identity:, store_identity:).call(identity:)
  end

  let(:fetch_identity) { instance_spy(AcmeIntegration::Identities::Fetch) }
  let(:store_identity) { instance_spy(AcmeIntegration::Identities::Store) }

  let!(:client) { create(:client) }
  let!(:identity) do
    create(:acme_integration_identity, client:, access_token: "whatever")
  end
  let(:attributes) do
    build(:acme_integration_identity_attributes, id: identity.external_id)
  end

  let(:fetching_error) { nil }

  before do
    allow(fetch_identity).to receive(:call) do
      fetching_error ? raise(fetching_error) : attributes
    end
    allow(store_identity).to receive(:call) { identity }
  end

  context "when access token is still valid" do
    it "fetches identity attributes from Acme and updates the identity" do
      sync

      expect(fetch_identity).to have_received(:call).with(access_token: "whatever")
      expect(store_identity).to have_received(:call).with(client:, attributes:)
    end
  end

  context "when access token became invalid" do
    let(:fetching_error) { AcmeIntegration::AccessTokenInvalidError }

    it "updates identity with all permissions set to false" do
      sync

      expect(fetch_identity).to have_received(:call).with(access_token: "whatever")
      expect(store_identity).to have_received(:call).with(
        client:,
        attributes: have_attributes(
          id: identity.external_id,
          name: identity.name,
          avatar_url: identity.avatar_url,
          access_token: nil,
          permission_public_profile_read: false,
          permission_pages_read: false,
          permission_page_comments_read: false,
          permission_page_comments_manage: false
        )
      )
    end
  end

  context "when fetching fails for another reason" do
    let(:fetching_error) { Acme::Error }
    it { expect { sync }.to raise_error(Acme::Error) }
  end
end
