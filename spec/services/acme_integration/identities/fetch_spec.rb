require "rails_helper"

RSpec.describe AcmeIntegration::Identities::Fetch do
  subject(:fetch) do
    described_class.new(api_client:).call(access_token: 'whatever')
  end

  let(:api_client) { instance_spy(Acme::ApiClient) }
  let(:raw_identity) { build(:acme_api_identity) }

  let(:get_identity_response) { ->(_) { raw_identity } }

  before do
    allow(api_client)
      .to receive(:get_identity)
      .with(access_token: 'whatever', &get_identity_response)
  end

  context "when Acme responds with identity"
  context "when Acme responds with authentication error" do
    let(:get_identity_response) do
      ->(_) { raise Acme::AuthenticationError }
    end

    it { expect { fetch }.to raise_error(AcmeIntegration::AccessTokenInvalidError) }
  end

  context "when Acme responds with permission missing error" do
    let(:get_identity_response) do
      ->(_) { raise Acme::ClientError, "permission missing" }
    end

    it { expect { fetch }.to raise_error(AcmeIntegration::PermissionMissingError) }
  end

  context "when Acme responds with other error" do
    let(:get_identity_response) do
      ->(_) { raise Acme::ClientError, "whatever" }
    end

    it { expect { fetch }.to raise_error(Acme::ClientError) }
  end
end
