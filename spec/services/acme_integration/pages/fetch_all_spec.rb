require "rails_helper"

RSpec.describe AcmeIntegration::Pages::FetchAll do
  subject(:fetch_all) do
    described_class.new(api_client:).call(access_token: 'whatever')
  end

  let(:api_client) { instance_spy(Acme::ApiClient) }
  let(:raw_pages) do
    [
      build(:acme_api_page, manager: true),
      build(:acme_api_page, manager: false)
    ]
  end

  let(:get_pages_response) { ->(_) { raw_pages } }

  before do
    allow(api_client)
      .to receive(:get_pages)
      .with(access_token: 'whatever', &get_pages_response)
  end

  context "when Acme responds with a list of pages" do
    it "parses and returns page attributes" do
      expect(fetch_all).to all(be_a(AcmeIntegration::Pages::Attributes))
      expect(fetch_all).to match_array([
        have_attributes(
          id: raw_pages[0]["id"],
          name: raw_pages[0]["name"],
          avatar_url: raw_pages[0]["avatar_url"],
          manager_role_granted: true
        ),
        have_attributes(
          id: raw_pages[1]["id"],
          name: raw_pages[1]["name"],
          avatar_url: raw_pages[1]["avatar_url"],
          manager_role_granted: false
        )
      ])
    end
  end

  context "when Acme responds with authentication error" do
    let(:get_pages_response) { ->(_) { raise Acme::AuthenticationError } }
    it { expect { fetch_all }.to raise_error(AcmeIntegration::AccessTokenInvalidError) }
  end

  context "when Acme responds with permission missing error" do
    let(:get_pages_response) do
      ->(_) { raise Acme::ClientError, "permission missing" }
    end

    it { expect { fetch_all }.to raise_error(AcmeIntegration::PermissionMissingError) }
  end

  context "when Acme responds with other error" do
    let(:get_pages_response) { ->(_) { raise Acme::ClientError, "whatever" } }
    it { expect { fetch_all }.to raise_error(Acme::ClientError) }
  end
end
