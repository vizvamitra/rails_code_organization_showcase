require "rails_helper"

RSpec.describe AcmeIntegration::Identities::Fetch do
  subject(:fetch) do
    described_class.new(api_client:).call(access_token: 'whatever')
  end

  let(:api_client) { instance_spy(Acme::ApiClient) }
  let(:raw_identity) do
    build(
      :acme_api_identity,
      public_profile_read:,
      pages_read:,
      page_comments_read:,
      page_comments_manage:
    )
  end

  let(:public_profile_read) { true }
  let(:pages_read) { true }
  let(:page_comments_read) { true }
  let(:page_comments_manage) { true }
  let(:get_identity_response) { ->(_) { { "data" => raw_identity } } }

  before do
    allow(api_client)
      .to receive(:get_identity)
      .with(access_token: 'whatever', &get_identity_response)
  end

  shared_examples "parses and returns identity attributes" do
    it "parses and returns identity attributes" do
      expect(fetch).to be_a(AcmeIntegration::Identities::Attributes)
      expect(fetch).to have_attributes(
        id: raw_identity["id"],
        access_token: "whatever",
        name: raw_identity["name"],
        avatar_url: raw_identity["avatar_url"],
        permission_public_profile_read: public_profile_read,
        permission_pages_read: pages_read,
        permission_page_comments_read: page_comments_read,
        permission_page_comments_manage: page_comments_manage
      )
    end
  end

  context "when Acme responds with identity" do
    context "when all permissions are granted" do
      include_examples "parses and returns identity attributes"
    end

    context "when `public_profile_read` permission is missing" do
      let(:public_profile_read) { false }
      include_examples "parses and returns identity attributes"
    end

    context "when `pages_read` permission is missing" do
      let(:pages_read) { false }
      include_examples "parses and returns identity attributes"
    end

    context "when `page_comments_read` permission is missing" do
      let(:page_comments_read) { false }
      include_examples "parses and returns identity attributes"
    end

    context "when `page_comments_manage` permission is missing" do
      let(:page_comments_manage) { false }
      include_examples "parses and returns identity attributes"
    end
  end

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
