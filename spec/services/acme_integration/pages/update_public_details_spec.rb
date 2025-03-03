require "rails_helper"

RSpec.describe AcmeIntegration::Pages::UpdatePublicDetails do
  subject(:update) do
    described_class.new.call(page:, name: "test", avatar_url: "https://foo.bar")
  end

  let(:page) { create(:acme_integration_page) }

  it "updates the page" do
    expect { update }.to change { page.reload.attributes }.to include(
      "name" => "test",
      "avatar_url" => "https://foo.bar"
    )
  end
end
