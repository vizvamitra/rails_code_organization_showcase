require "rails_helper"

RSpec.describe "api/acme/identities", type: :request do
  let(:identity_object) do
    {
      "id" => be_an(Integer),
      "client_id" => be_an(Integer),
      "facebook_id" => be_a(String),
      "name" => be_a(String),
      "avatar_url" => be_a(String),
      "access_status" => be_a(String),
      "access_token_valid" => be_truthy.or(be_falsey),
      "can_discover_pages" => be_truthy.or(be_falsey),
      "can_moderate_comments" => be_truthy.or(be_falsey)
    }
  end

  let(:headers) do
    return {} if !authenticated
    { "Authorization" => "Bearer #{user.access_token}" }
  end

  let!(:client) { create(:client) }
  let!(:user) { create(:user, client:) }

  let(:authenticated) { true }

  describe "POST /api/acme/identities" do
    subject(:request) { -> { post("/api/acme/identities", params:, headers:) } }

    let(:params) { { identity: { access_token: "whatever" } } }
    let(:identity) { create(:acme_integration_identity) }

    let(:create_result) { ->(*) { identity } }

    before do
      allow_any_instance_of(AcmeIntegration::Interface)
        .to receive(:create_identity, &create_result)

      request.call
    end

    context "when access_token is valid" do
      it "responds with 201 and Acme Identity object" do
        expect(response).to have_http_status(201)
        expect(json["data"]).to match(identity_object)
      end
    end

    context "when access_token is invalid" do
      let(:create_result) { ->(*) { raise ::AcmeIntegration::AccessTokenInvalidError } }

      it "responds with 422" do
        expect(response).to have_http_status(422)
        expect(json["errors"].first).to include("title" => "unprocessable_content")
      end
    end

    context "when permission is missing" do
      let(:create_result) { ->(*) { raise ::AcmeIntegration::PermissionMissingError } }

      it "responds with 422" do
        expect(response).to have_http_status(422)
        expect(json["errors"].first).to include("title" => "unprocessable_content")
      end
    end

    context "when access_token is not passed" do
      let(:params) { { identity: {} } }

      it "responds with 400" do
        expect(response).to have_http_status(400)
        expect(json["errors"].first).to include("title" => "bad_request")
      end
    end

    context "when user is not authenticated" do
      let(:authenticated) { false }

      it "responds with 401" do
        expect(response).to have_http_status(401)
        expect(json["errors"].first).to include("title" => "unauthorized")
      end
    end
  end
end
