require "rails_helper"

RSpec.describe AcmeIntegration::Pages::UpdateAccessDetails do
  subject(:update) do
    described_class.new.call(
      page:,
      access_provider:,
      discoverable:,
      manager_role_granted:
    )
  end

  let(:page) { create(:acme_integration_page) }
  let(:identity) { create(:acme_integration_identity) }

  let(:access_provider) { identity }
  let(:discoverable) { true }
  let(:manager_role_granted) { true }

  shared_examples "updates the page, setting status to" do |status|
    it "updates the page, setting status to '#{status}'" do
      expect { update }.to change { page.reload.attributes }.to include(
        "access_provider_id" => access_provider&.id,
        "discoverable" => discoverable,
        "manager_role_granted" => manager_role_granted,
        "status" => status
      )
    end
  end

  context "when page is operable" do
    include_examples "updates the page, setting status to", "operable"
  end

  context "when page is not discoverable" do
    let(:access_provider) { nil }
    let(:discoverable) { false }
    let(:manager_role_granted) { false }

    include_examples "updates the page, setting status to", "undiscoverable"
  end

  context "when manager role is not granted" do
    let(:manager_role_granted) { false }
    include_examples "updates the page, setting status to", "inoperable"
  end
end
