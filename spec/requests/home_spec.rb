require 'rails_helper'

RSpec.describe "Homes", type: :request do
  describe "GET /index" do
    let(:user) { create(:user) }

    before { sign_in(user) }

    it "returns http success" do
      get "/home"
      expect(response).to have_http_status(:success)
    end
  end
end
