require "rails_helper"

RSpec.describe AcmeIntegration::Pages::IsPreferredAccessProvider do
  subject(:is_preferred) do
    described_class.new.call(page:, candidate:, operable_by_candidate:)
  end

  let(:page) do
    build(
      :acme_integration_page,
      access_provider: current_provider,
      status: current_status
    )
  end
  let(:candidate) { build(:acme_integration_identity) }
  let(:current_status) { :operable }
  let(:operable_by_candidate) { true }

  let(:current_provider) { nil }

  context "when no current provider" do
    it { is_expected.to eq(true) }
  end

  context "when candidate is the current provider" do
    let(:current_provider) { candidate }
    it { is_expected.to eq(true) }
  end

  context "when candidate is not the current provider" do
    let(:current_provider) { build(:acme_integration_identity) }

    context "when operable by both providers" do
      it { is_expected.to eq(false) }
    end

    context "when operable only by current provider" do
      let(:operable_by_candidate) { false }
      it { is_expected.to eq(false) }
    end

    context "when operable only by candidate provider" do
      let(:current_status) { :inoperable }
      it { is_expected.to eq(true) }
    end
  end
end
