require "rails_helper"

RSpec.describe Moderation::Assets::ToggleModeration do
  subject(:toggle) do
    described_class
      .new(acme_integration:)
      .call(client_id:, asset_id:, active: requested_status)
  end

  let(:acme_integration) { instance_spy(AcmeIntegration::Interface) }

  let(:clients) { create_pair(:client) }
  let!(:asset) do
    create(:moderation_asset, client: clients[0], active:, access_acquired:)
  end

  let(:client_id) { clients[0].id }
  let(:asset_id) { asset.id }
  let(:active) { false }
  let(:access_acquired) { true }
  let(:requested_status) { true }

  before do
    allow(acme_integration).to receive(:toggle_page_comment_retrieval)
  end

  shared_examples "activates asset" do
    it "activates asset" do
      expect { toggle }.to change { asset.reload.active }.to(true)

      expect(acme_integration)
        .to have_received(:toggle_page_comment_retrieval)
        .with(public_id: asset.public_id, retrieve_comments: true)
    end
  end

  shared_examples "deactivates asset" do
    it "deactivates asset" do
      expect { toggle }.to change { asset.reload.active }.to(false)

      expect(acme_integration)
        .to have_received(:toggle_page_comment_retrieval)
        .with(public_id: asset.public_id, retrieve_comments: false)
    end
  end

  shared_examples "does nothing" do
    it "does nothing" do
      expect { toggle }.not_to change { asset.reload.attributes }
      expect(acme_integration).not_to have_received(:toggle_page_comment_retrieval)
    end
  end

  context "when activating" do
    context "inactive moderatable asset" do
      include_examples "activates asset"
    end

    context "inactive non-moderatable asset" do
      let(:access_acquired) { false }

      it "fails with Moderation::AssetNotModeratableError" do
        expect { toggle }.to raise_error(Moderation::AssetNotModeratableError)
        expect(acme_integration).not_to have_received(:toggle_page_comment_retrieval)
      end
    end

    context "active asset" do
      let(:active) { true }
      include_examples "does nothing"
    end
  end

  context "when deactivating" do
    let(:requested_status) { false }

    context "active asset" do
      let(:active) { true }
      include_examples "deactivates asset"
    end

    context "inactive asset" do
      include_examples "does nothing"
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
