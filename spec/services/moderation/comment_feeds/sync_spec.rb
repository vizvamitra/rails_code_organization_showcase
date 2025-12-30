require "rails_helper"

RSpec.describe Moderation::CommentFeeds::Sync do
  subject(:sync) do
    described_class.new.call(
      client_id:,
      platform: :acme,
      public_id:,
      upstream_id:,
      **attributes
    )
  end

  let(:client) { create(:client) }

  let(:client_id) { client.id }
  let(:public_id) { SecureRandom.uuid }
  let(:upstream_id) { SecureRandom.hex(10) }
  let(:attributes) do
    {
      title: "test",
      url: "example.com",
      avatar_url: "example.com/avatar.png"
    }
  end

  context "when comment feeds doesn't yet exist" do
    it "creates new comment feed" do
      expect { sync }
        .to change(Moderation::CommentFeed, :count).by(1)
        .and change { client.moderation_comment_feeds.exists?(public_id:) }.to(true)

      expect(client.moderation_comment_feeds.find_by(public_id:)).to have_attributes(
        platform: "acme",
        upstream_id:,
        title: "test",
        url: "example.com",
        avatar_url: "example.com/avatar.png"
      )
    end
  end

  context "when comment feeds already exists" do
    let!(:comment_feed) do
      create(
        :moderation_comment_feed,
        client:,
        public_id:,
        upstream_id: "0000000000",
        title: "foo",
        url: "bar",
        avatar_url: "baz"
      )
    end

    context "when comment feed belongs to the given client" do
      it "updates existing comment feed" do
        expect { sync }
          .to preserve(Moderation::CommentFeed, :count)
          .and preserve { comment_feed.reload.public_id }
          .and preserve { comment_feed.reload.upstream_id }
          .and change { comment_feed.reload.attributes }.to include(
            "title" => "test",
            "url" => "example.com",
            "avatar_url" => "example.com/avatar.png"
          )
      end
    end

    context "when comment feed belongs to another client" do
      let(:client_id) { 123 }
      it { expect { sync }.to raise_error(ActiveRecord::RecordNotFound) }
    end
  end

  context "when some attributes are missing" do
    let(:attributes) { { title: "test" } }
    it { expect { sync }.to raise_error(NoMatchingPatternError) }
  end
end
