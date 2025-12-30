require "rails_helper"

RSpec.describe Moderation::CommentFeeds::ToggleConnectionStatus do
  subject(:toggle) do
    described_class.new.call(public_id:, connected: true)
  end

  let!(:comment_feed) { create(:moderation_comment_feed) }

  let(:public_id) { comment_feed.public_id }

  context "when comment feed exists" do
    it "updates access status of the given comment feed" do
      expect { toggle }.to change { comment_feed.reload.connected }.to(true)
    end
  end

  context "when comment feed doesn't exist" do
    let(:public_id) { "invalid" }
    it { expect { toggle }.to raise_error(ActiveRecord::RecordNotFound) }
  end
end
