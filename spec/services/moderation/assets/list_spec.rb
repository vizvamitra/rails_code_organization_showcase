require "rails_helper"

RSpec.describe Moderation::Assets::List do
  subject(:list_assets) do
    described_class.new.call(
      client_id:,
      source:,
      title:,
      access_acquired:,
      order:
    )
  end

  let(:client) { create(:client) }
  let(:assets) do
    [
      [client,          :acme,  "Beta", true],
      [client,          :meta, "Alpha", false],
      [create(:client), :acme,   "Foo", true]
    ].map do |owner, source, title, access_acquired|
      create(:moderation_asset, client: owner, source:, title:, access_acquired:)
    end
  end

  let(:client_id) { client.id }
  let(:source) { nil }
  let(:title) { nil }
  let(:access_acquired) { nil }
  let(:order) { nil }

  context "when no filters/ordering applied" do
    it "returns all client's assets, ordered by title asc" do
      expect(list_assets).to eq([assets[1], assets[0]])
    end
  end

  context "when filtering by source" do
    let(:source) { "acme" }
    it { expect(list_assets).to eq([assets[0]]) }
  end

  context "when filtering by title" do
    let(:title) { "Be" }

    it { expect(list_assets).to eq([assets[0]]) }
  end

  context "when filtering by access status" do
    let(:access_acquired) { false }
    it { expect(list_assets).to eq([assets[1]]) }
  end

  context "when ordering by source ascending" do
    let(:order) { "source" }
    it { expect(list_assets).to eq([assets[0], assets[1]]) }
  end

  context "when ordering by source descending" do
    let(:order) { "-source" }
    it { expect(list_assets).to eq([assets[1], assets[0]]) }
  end

  context "when ordering by title ascending" do
    let(:order) { "title" }
    it { expect(list_assets).to eq([assets[1], assets[0]]) }
  end

  context "when ordering by title descending" do
    let(:order) { "-title" }
    it { expect(list_assets).to eq([assets[0], assets[1]]) }
  end

  context "when ordering by access status ascending" do
    let(:order) { "access_acquired" }
    it { expect(list_assets).to eq([assets[1], assets[0]]) }
  end

  context "when ordering by access status descending" do
    let(:order) { "-access_acquired" }
    it { expect(list_assets).to eq([assets[0], assets[1]]) }
  end

  context "when ordering by an invalid field" do
    let(:order) { "-whatever" }

    it "falls back to default ordering" do
      expect(list_assets).to eq([assets[1], assets[0]])
    end
  end

  context "when client doesn't exist" do
    let(:client_id) { "invalid" }
    it { expect { list_assets }.to raise_error(ActiveRecord::RecordNotFound) }
  end
end
