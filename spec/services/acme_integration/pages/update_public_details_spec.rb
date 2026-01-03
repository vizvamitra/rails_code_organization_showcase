require "rails_helper"

RSpec.describe AcmeIntegration::Pages::UpdatePublicDetails do
  subject(:update) do
    described_class
      .new(moderation:)
      .call(page:, name: "test", avatar_url: "https://foo.bar")
  end

  let(:moderation) { instance_spy(Moderation::Interface) }

  let(:page) { create(:acme_integration_page) }

  before { allow(moderation).to receive(:sync_comment_feed) }

  it "updates the page and notifies moderation subsystem" do
    expect { update }.to change { page.reload.attributes }.to include(
      "name" => "test",
      "avatar_url" => "https://foo.bar"
    )

    expect(moderation).to have_received(:sync_comment_feed).with(
      client_id: page.client_id,
      platform: :acme,
      public_id: page.public_id,
      upstream_id: page.acme_id,
      title: "test",
      url: page.url,
      avatar_url: "https://foo.bar"
    )
  end
end
