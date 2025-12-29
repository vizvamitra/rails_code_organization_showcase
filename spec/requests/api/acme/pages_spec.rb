require "rails_helper"

RSpec.describe "api/acme/pages", type: :request do
  describe "GET /api/acme/pages" do
    subject(:request) { -> { get("/api/acme/pages", headers:) } }

    let(:headers) do
      return {} if !authenticated
      { "Authorization" => "Bearer #{user.access_token}" }
    end

    let(:page_object) do
      {
        "id" => be_an(Integer),
        "client_id" => be_an(Integer),
        "public_id" => be_a(String),
        "external_id" => be_a(String),
        "name" => be_a(String),
        "avatar_url" => be_a(String),
        "status" => be_a(String),
        "discoverable" => be_truthy.or(be_falsey),
        "manager_role_granted" => be_truthy.or(be_falsey)
      }
    end

    let!(:client) { create(:client) }
    let!(:user) { create(:user, client:) }
    let!(:identity) { create(:acme_integration_identity, client:) }
    let!(:pages) do
      [
        create(:acme_integration_page, client:, name: "CCC"),
        create(:acme_integration_page, client:, name: "AAA"),
        create(:acme_integration_page, name: "AAA") # other client
      ]
    end

    let(:authenticated) { true }

    before { request.call }

    context "when access_token is valid" do
      it "responds with 200 and current user's acme pages, ordered by name" do
        expect(response).to have_http_status(200)
        expect(json["data"]).to all(match(page_object))
        expect(json["data"]).to match([
          include("id" => pages[1].id),
          include("id" => pages[0].id)
        ])
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
