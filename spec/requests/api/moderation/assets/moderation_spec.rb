require "rails_helper"

RSpec.describe "api/moderation/assets/:id/moderation", type: :request do
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
      "moderated" => be_truthy.or(be_falsey),
      "access_acquired" => be_truthy.or(be_falsey)
    }
  end

  let!(:client) { create(:client) }
  let!(:user) { create(:user, client:) }
  let!(:asset) { create(:moderation_asset, client:, moderated: initial_moderated) }
  let!(:page) { create(:acme_integration_page, public_id: asset.public_id) }

  let(:authenticated) { true }
  let(:asset_id) { asset.id }

  before { request.call }

  describe "POST /api/moderation/assets/:id/moderation" do
    subject(:request) { -> { post("/api/moderation/assets/#{asset_id}/moderation", headers:) } }

    let(:initial_moderated) { false }

    context "when asset exists" do
      it "responds with 200 and the asset" do
        expect(response).to have_http_status(200)
        expect(json["data"]).to match(asset_object)
        expect(json["data"]["moderated"]).to be(true)
      end
    end

    context "when asset doesn't exist" do
      let(:asset_id) { "whatever" }

      it "responds with 404" do
        expect(response).to have_http_status(404)
        expect(json["errors"].first).to include("title" => "not_found")
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

  describe "DELETE /api/moderation/assets/:id/moderation" do
    subject(:request) { -> { delete("/api/moderation/assets/#{asset_id}/moderation", headers:) } }

    let(:initial_moderated) { true }

    context "when asset exists" do
      it "responds with 200 and the asset" do
        expect(response).to have_http_status(200)
        expect(json["data"]).to match(asset_object)
        expect(json["data"]["moderated"]).to be(false)
      end
    end

    context "when asset doesn't exist" do
      let(:asset_id) { "whatever" }

      it "responds with 404" do
        expect(response).to have_http_status(404)
        expect(json["errors"].first).to include("title" => "not_found")
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
