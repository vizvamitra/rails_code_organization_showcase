require "rails_helper"

RSpec.describe "api/moderation/assets", type: :request do
  describe "GET /api/moderation/assets" do
    subject(:request) { -> { get("/api/moderation/assets", headers:) } }

    let(:headers) do
      return {} if !authenticated
      { "Authorization" => "Bearer #{user.access_token}" }
    end

    let(:asset_object) do
      {
        "id" => be_an(Integer),
        "client_id" => be_an(Integer),
        "source" => be_a(String),
        "title" => be_a(String),
        "url" => be_a(String),
        "avatar_url" => be_a(String),
        "active" => be_truthy.or(be_falsey),
        "access_acquired" => be_truthy.or(be_falsey)
      }
    end

    let!(:client) { create(:client) }
    let!(:user) { create(:user, client:) }
    let!(:assets) do
      [
        create(:moderation_asset, client:),
        create(:moderation_asset, client:),
        create(:moderation_asset) # other client
      ]
    end

    let(:authenticated) { true }

    before { request.call }

    context "when user is authenticated" do
      it "responds with 200 and current client's assets" do
        expect(response).to have_http_status(200)
        expect(json["data"]).to all(match(asset_object))
        expect(json["data"]).to match_array([
          include("id" => assets[0].id),
          include("id" => assets[1].id)
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
