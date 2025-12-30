require "rails_helper"

RSpec.describe "api/moderation/comment_feeds", type: :request do
  describe "GET /api/moderation/comment_feeds" do
    subject(:request) { -> { get("/api/moderation/comment_feeds", headers:) } }

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
    let!(:comment_feeds) do
      [
        create(:moderation_comment_feed, client:),
        create(:moderation_comment_feed, client:),
        create(:moderation_comment_feed) # other client
      ]
    end

    let(:authenticated) { true }

    before { request.call }

    context "when user is authenticated" do
      it "responds with 200 and current client's comment feeds" do
        expect(response).to have_http_status(200)
        expect(json["data"]).to all(match(comment_feed_object))
        expect(json["data"]).to match_array([
          include("id" => comment_feeds[0].id),
          include("id" => comment_feeds[1].id)
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
