require "rails_helper"

RSpec.describe Moderation::Assets::ToggleModeration do
  subject(:toggle) do
    described_class
      .new(acme_integration:)
      .call(client_id:, asset_id:, moderated: requested_status)
  end

  let(:acme_integration) { instance_spy(AcmeIntegration::Interface) }

  let(:clients) { create_pair(:client) }
  let!(:asset) do
    create(:moderation_asset, client: clients[0], moderated: initial_status)
  end

  let(:client_id) { clients[0].id }
  let(:asset_id) { asset.id }
  let(:initial_status) { false }
  let(:requested_status) { !initial_status }

  before do
    allow(acme_integration).to receive(:toggle_page_comment_retrieval)
  end

  context "when asset moderation status differs from requested" do
    it "updates access status of the given asset" do
      expect { toggle }.to change { asset.reload.moderated }.to(true)

      expect(acme_integration)
        .to have_received(:toggle_page_comment_retrieval)
        .with(public_id: asset.public_id, retrieve_comments: requested_status)
    end
  end

  context "when asset moderation status matches the requested" do
    let(:requested_status) { initial_status }

    it "does no changes" do
      expect { toggle }.not_to change { asset.reload.attributes }
      expect(acme_integration).not_to have_received(:toggle_page_comment_retrieval)
    end
  end

  context "when asset doesn't exist" do
    let(:asset_id) { "invalid" }

    it "fails with ActiveRecord::RecordNotFound" do
      expect { toggle }.to raise_error(ActiveRecord::RecordNotFound)
      expect(acme_integration).not_to have_received(:toggle_page_comment_retrieval)
    end
  end

  context "when asset belongs to another client" do
    let(:client_id) { clients[1].id }

    it "fails with ActiveRecord::RecordNotFound" do
      expect { toggle }.to raise_error(ActiveRecord::RecordNotFound)
      expect(acme_integration).not_to have_received(:toggle_page_comment_retrieval)
    end
  end
end
