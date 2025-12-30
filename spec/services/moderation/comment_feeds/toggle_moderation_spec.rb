require "rails_helper"

RSpec.describe Moderation::CommentFeeds::ToggleModeration do
  subject(:toggle) do
    described_class
      .new(acme_integration:)
      .call(client_id:, comment_feed_id:, moderated: requested_status)
  end

  let(:acme_integration) { instance_spy(AcmeIntegration::Interface) }

  let(:clients) { create_pair(:client) }
  let!(:comment_feed) do
    create(:moderation_comment_feed, client: clients[0], moderated:, connected:)
  end

  let(:client_id) { clients[0].id }
  let(:comment_feed_id) { comment_feed.id }
  let(:moderated) { false }
  let(:connected) { true }
  let(:requested_status) { true }

  before do
    allow(acme_integration).to receive(:toggle_page_comment_retrieval)
  end

  shared_examples "activates comment feed moderation" do
    it "activates comment feed moderation" do
      expect { toggle }.to change { comment_feed.reload.moderated }.to(true)

      expect(acme_integration)
        .to have_received(:toggle_page_comment_retrieval)
        .with(public_id: comment_feed.public_id, retrieve_comments: true)
    end
  end

  shared_examples "deactivates comment feed moderation" do
    it "deactivates comment feed moderation" do
      expect { toggle }.to change { comment_feed.reload.moderated }.to(false)

      expect(acme_integration)
        .to have_received(:toggle_page_comment_retrieval)
        .with(public_id: comment_feed.public_id, retrieve_comments: false)
    end
  end

  shared_examples "does nothing" do
    it "does nothing" do
      expect { toggle }.not_to change { comment_feed.reload.attributes }
      expect(acme_integration).not_to have_received(:toggle_page_comment_retrieval)
    end
  end

  context "when activating" do
    context "not moderated connected comment feed" do
      include_examples "activates comment feed moderation"
    end

    context "not moderated disconnected comment feed" do
      let(:connected) { false }

      it "fails with Moderation::CommentFeedNotModeratableError" do
        expect { toggle }.to raise_error(Moderation::CommentFeedNotModeratableError)
        expect(acme_integration).not_to have_received(:toggle_page_comment_retrieval)
      end
    end

    context "moderated comment feed" do
      let(:moderated) { true }
      include_examples "does nothing"
    end
  end

  context "when deactivating" do
    let(:requested_status) { false }

    context "moderted comment feed" do
      let(:moderated) { true }
      include_examples "deactivates comment feed moderation"
    end

    context "not moderated comment feed" do
      include_examples "does nothing"
    end
  end

  context "when comment feed doesn't exist" do
    let(:comment_feed_id) { "invalid" }

    it "fails with ActiveRecord::RecordNotFound" do
      expect { toggle }.to raise_error(ActiveRecord::RecordNotFound)
      expect(acme_integration).not_to have_received(:toggle_page_comment_retrieval)
    end
  end

  context "when comment feed belongs to another client" do
    let(:client_id) { clients[1].id }

    it "fails with ActiveRecord::RecordNotFound" do
      expect { toggle }.to raise_error(ActiveRecord::RecordNotFound)
      expect(acme_integration).not_to have_received(:toggle_page_comment_retrieval)
    end
  end
end
