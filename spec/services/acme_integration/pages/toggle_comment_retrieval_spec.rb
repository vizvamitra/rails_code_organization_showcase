require "rails_helper"

RSpec.describe AcmeIntegration::Pages::ToggleCommentRetrieval do
  subject(:toggle) do
    described_class.new.call(public_id:, retrieve_comments: requested_status)
  end

  let!(:page) do
    create(:acme_integration_page, retrieve_comments: initial_status)
  end

  let(:public_id) { page.public_id }
  let(:initial_status) { false }
  let(:requested_status) { !initial_status }

  context "when comment retrieval status differs from requested" do
    it "updates comment retrieval status" do
      expect { toggle }.to change { page.reload.retrieve_comments }.to(true)
    end
  end

  context "when comment retrieval status matches the requested" do
    let(:requested_status) { initial_status }
    it { expect { toggle }.not_to change { page.reload.attributes } }
  end

  context "when page doesn't exist" do
    let(:public_id) { "invalid" }
    it { expect { toggle }.to raise_error(ActiveRecord::RecordNotFound) }
  end
end
