require "rails_helper"

RSpec.describe Moderation::Assets::Sync do
  subject(:sync) do
    described_class.new.call(
      client_id:,
      source: :acme,
      public_id:,
      external_id:,
      **attributes
    )
  end

  let(:client) { create(:client) }

  let(:client_id) { client.id }
  let(:public_id) { SecureRandom.uuid }
  let(:external_id) { SecureRandom.hex(10) }
  let(:attributes) do
    {
      title: "test",
      url: "example.com",
      avatar_url: "example.com/avatar.png"
    }
  end

  context "when assets doesn't yet exist" do
    it "creates new asset" do
      expect { sync }
        .to change(Moderation::Asset, :count).by(1)
        .and change { client.moderation_assets.exists?(public_id:) }.to(true)

      expect(client.moderation_assets.find_by(public_id:)).to have_attributes(
        source: "acme",
        external_id:,
        title: "test",
        url: "example.com",
        avatar_url: "example.com/avatar.png"
      )
    end
  end

  context "when assets already exists" do
    let!(:asset) do
      create(
        :moderation_asset,
        client:,
        public_id:,
        external_id: "0000000000",
        title: "foo",
        url: "bar",
        avatar_url: "baz"
      )
    end

    context "when asset belongs to the given client" do
      it "updates existing asset" do
        expect { sync }
          .to preserve(Moderation::Asset, :count)
          .and preserve { asset.reload.public_id }
          .and preserve { asset.reload.external_id }
          .and change { asset.reload.attributes }.to include(
            "title" => "test",
            "url" => "example.com",
            "avatar_url" => "example.com/avatar.png"
          )
      end
    end

    context "when asset belongs to another client" do
      let(:client_id) { 123 }
      it { expect { sync }.to raise_error(ActiveRecord::RecordNotFound) }
    end
  end

  context "when some attributes are missing" do
    let(:attributes) { { title: "test" } }
    it { expect { sync }.to raise_error(NoMatchingPatternError) }
  end
end
