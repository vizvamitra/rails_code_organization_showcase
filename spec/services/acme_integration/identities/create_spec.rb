require "rails_helper"

RSpec.describe AcmeIntegration::Identities::Create do
  subject(:create_identity) do
    described_class
      .new(fetch_identity:, store_identity:)
      .call(client_id:, access_token: "whatever")
  end

  let(:fetch_identity) { instance_spy(AcmeIntegration::Identities::Fetch) }
  let(:store_identity) { instance_spy(AcmeIntegration::Identities::Store) }

  let!(:client) { create(:client) }
  let(:attributes) { build(:acme_integration_identity_attributes) }
  let(:identity) do
    build(:acme_integration_identity, external_id: attributes.id)
  end

  let(:client_id) { client.id }
  let(:fetching_error) { nil }

  before do
    allow(fetch_identity).to receive(:call).with(access_token: "whatever") do
      fetching_error ? raise(fetching_error) : attributes
    end
    allow(store_identity).to receive(:call).with(client:, attributes:) { identity }
  end

  it "returns fetches identity from Acme, stores it and refreshes access status" do
    expect(create_identity).to eq(identity)

    expect(fetch_identity).to have_received(:call).with(access_token: "whatever")
    expect(store_identity).to have_received(:call).with(client:, attributes:)
  end

  context "when client can't be found" do
    let(:client_id) { "invalid" }
    it { expect { create_identity }.to raise_error(ActiveRecord::RecordNotFound) }
  end

  context "when access token is invalid" do
    let(:fetching_error) { AcmeIntegration::AccessTokenInvalidError }
    it do
      expect { create_identity }.to raise_error(AcmeIntegration::AccessTokenInvalidError)
    end
  end

  context "when fetching fails for another reason" do
    let(:fetching_error) { Acme::Error }
    it { expect { create_identity }.to raise_error(Acme::Error) }
  end
end
