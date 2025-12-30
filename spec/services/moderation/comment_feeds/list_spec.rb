require "rails_helper"

RSpec.describe Moderation::CommentFeeds::List do
  subject(:list) do
    described_class.new.call(
      client_id:,
      platform:,
      title:,
      connected:,
      order:
    )
  end

  let(:client) { create(:client) }
  let(:feeds) do
    [
      [client,          :acme,  "Beta", true],
      [client,          :meta, "Alpha", false],
      [create(:client), :acme,   "Foo", true]
    ].map do |owner, platform, title, connected|
      create(:moderation_comment_feed, client: owner, platform:, title:, connected:)
    end
  end

  let(:client_id) { client.id }
  let(:platform) { nil }
  let(:title) { nil }
  let(:connected) { nil }
  let(:order) { nil }

  context "when no filters/ordering applied" do
    it "returns all client's comment feeds, ordered by title asc" do
      expect(list).to eq([feeds[1], feeds[0]])
    end
  end

  context "when filtering by platform" do
    let(:platform) { "acme" }
    it { expect(list).to eq([feeds[0]]) }
  end

  context "when filtering by title" do
    let(:title) { "Be" }

    it { expect(list).to eq([feeds[0]]) }
  end

  context "when filtering by access status" do
    let(:connected) { false }
    it { expect(list).to eq([feeds[1]]) }
  end

  context "when ordering by platform ascending" do
    let(:order) { "platform" }
    it { expect(list).to eq([feeds[0], feeds[1]]) }
  end

  context "when ordering by platform descending" do
    let(:order) { "-platform" }
    it { expect(list).to eq([feeds[1], feeds[0]]) }
  end

  context "when ordering by title ascending" do
    let(:order) { "title" }
    it { expect(list).to eq([feeds[1], feeds[0]]) }
  end

  context "when ordering by title descending" do
    let(:order) { "-title" }
    it { expect(list).to eq([feeds[0], feeds[1]]) }
  end

  context "when ordering by access status ascending" do
    let(:order) { "connected" }
    it { expect(list).to eq([feeds[1], feeds[0]]) }
  end

  context "when ordering by access status descending" do
    let(:order) { "-connected" }
    it { expect(list).to eq([feeds[0], feeds[1]]) }
  end

  context "when ordering by an invalid field" do
    let(:order) { "-whatever" }

    it "falls back to default ordering" do
      expect(list).to eq([feeds[1], feeds[0]])
    end
  end

  context "when client doesn't exist" do
    let(:client_id) { "invalid" }
    it { expect { list }.to raise_error(ActiveRecord::RecordNotFound) }
  end
end
