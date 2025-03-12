require "rails_helper"

RSpec.describe Moderation::Assets::ToggleAccessStatus do
  subject(:toggle) do
    described_class.new.call(public_id:, access_acquired: true)
  end

  let!(:asset) { create(:moderation_asset) }

  let(:public_id) { asset.public_id }

  context "when asset exists" do
    it "updates access status of the given asset" do
      expect { toggle }.to change { asset.reload.access_acquired }.to(true)
    end
  end

  context "when asset doesn't exist" do
    let(:public_id) { "invalid" }
    it { expect { toggle }.to raise_error(ActiveRecord::RecordNotFound) }
  end
end
