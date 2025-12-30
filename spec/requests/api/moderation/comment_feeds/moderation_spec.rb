require "rails_helper"

RSpec.describe "api/moderation/comment_feeds/:id/moderation", type: :request do
  let(:headers) do
    return {} if !authenticated
    { "Authorization" => "Bearer #{user.access_token}" }
  end

  let(:comment_feed_object) do
    {
      "id" => be_an(Integer),
      "client_id" => be_an(Integer),
      "platform" => be_a(String),
      "public_id" => be_a(String),
      "title" => be_a(String),
      "url" => be_a(String),
      "avatar_url" => be_a(String),
      "moderated" => be_truthy.or(be_falsey),
      "connected" => be_truthy.or(be_falsey)
    }
  end

  let!(:client) { create(:client) }
  let!(:user) { create(:user, client:) }
  let!(:comment_feed) do
    create(:moderation_comment_feed, client:, moderated: initial_status, connected:)
  end
  let!(:page) { create(:acme_integration_page, public_id: comment_feed.public_id) }

  let(:authenticated) { true }
  let(:feed_id) { comment_feed.id }
  let(:connected) { true }

  before { request.call }

  describe "POST /api/moderation/comment_feeds/:id/activation" do
    subject(:request) do
      -> { post("/api/moderation/comment_feeds/#{feed_id}/moderation", headers:) }
    end

    let(:initial_status) { false }

    context "when comment feed is moderatable" do
      it "responds with 200 and the comment_feed" do
        expect(response).to have_http_status(200)
        expect(json["data"]).to match(comment_feed_object)
        expect(json["data"]["moderated"]).to be(true)
      end
    end

    context "when comment feed is not moderatable" do
      let(:connected) { false }

      it "responds with 409" do
        expect(response).to have_http_status(409)
        expect(json["errors"].first).to include("title" => "conflict")
      end
    end

    context "when comment feed doesn't exist" do
      let(:feed_id) { "whatever" }

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

  describe "DELETE /api/moderation/comment_feeds/:id/moderation" do
    subject(:request) do
      -> { delete("/api/moderation/comment_feeds/#{feed_id}/moderation", headers:) }
    end

    let(:initial_status) { true }

    context "when comment feed exists" do
      it "responds with 200 and the comment_feed" do
        expect(response).to have_http_status(200)
        expect(json["data"]).to match(comment_feed_object)
        expect(json["data"]["moderated"]).to be(false)
      end
    end

    context "when comment feed doesn't exist" do
      let(:feed_id) { "whatever" }

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
