require "rails_helper"

RSpec.describe "api/authentication", type: :request do
  describe "POST /api/authentication" do
    subject(:request) { -> { post("/api/authentication", params:) } }

    let!(:user) do
      create(:user, email_address: "test@example.com", password: "12345678")
    end

    let(:params) { { user: { email_address:, password: } } }
    let(:email_address) { "test@example.com" }
    let(:password) { "12345678" }

    before { request.call }

    context "when creadentials are correct" do
      it "responds with 200 and user" do
        expect(response).to have_http_status(200)
        expect(json["data"]).to include(
          "id" => user.id,
          "client_id" => user.client_id,
          "email_address" => user.email_address,
          "access_token" => user.access_token
        )
      end
    end

    context "when password is invalid" do
      let(:password) { "invalid" }

      it "responds with 404" do
        expect(response).to have_http_status(404)
        expect(json["errors"].first).to include("title" => "not_found")
      end
    end

    context "when user with given email doesn't exist" do
      let(:email_address) { "invalid" }

      it "responds with 404" do
        expect(response).to have_http_status(404)
        expect(json["errors"].first).to include("title" => "not_found")
      end
    end

    context "when creadentials are not provided" do
      let(:params) { {} }

      it "responds with 400" do
        expect(response).to have_http_status(400)
        expect(json["errors"].first).to include("title" => "bad_request")
      end
    end
  end
end
