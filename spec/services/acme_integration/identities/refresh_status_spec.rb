require "rails_helper"

RSpec.describe AcmeIntegration::Identities::RefreshStatus do
  subject(:refresh) { described_class.new.call(identity:) }

  let(:identity) do
    create(
      :acme_integration_identity,
      access_token:,
      permission_public_profile_read:,
      permission_pages_read:,
      permission_page_comments_read:,
      permission_page_comments_manage:,
      access_token_valid: false,
      can_discover_pages: false,
      can_moderate_comments: false,
      access_status: :revoked
    )
  end

  let(:access_token) { "present" }
  let(:permission_public_profile_read) { true }
  let(:permission_pages_read) { true }
  let(:permission_page_comments_read) { true }
  let(:permission_page_comments_manage) { true }

  context "when access token is present and all permissions are granted" do
    it "reflects full access" do
      expect { refresh }.to change { identity.reload.attributes }.to include(
        "access_token_valid" => true,
        "can_discover_pages" => true,
        "can_moderate_comments" => true,
        "access_status" => "full"
      )
    end
  end

  context "when access token is not present" do
    let(:access_token) { nil }

    it "reflects revoked access" do
      expect { refresh }.not_to change { identity.reload.attributes }
    end
  end

  context "when public_profile_read permission is missing" do
    let(:permission_public_profile_read) { false }

    it "reflects partial access" do
      expect { refresh }.to change { identity.reload.attributes }.to include(
        "access_token_valid" => true,
        "can_discover_pages" => false,
        "can_moderate_comments" => false,
        "access_status" => "partial"
      )
    end
  end

  context "when pages_read permission is missing" do
    let(:permission_pages_read) { false }

    it "reflects revoked access" do
      expect { refresh }.to change { identity.reload.attributes }.to include(
        "access_token_valid" => true,
        "can_discover_pages" => false,
        "can_moderate_comments" => false,
        "access_status" => "partial"
      )
    end
  end

  context "when page_comments_read permission is missing" do
    let(:permission_page_comments_read) { false }

    it "reflects revoked access" do
      expect { refresh }.to change { identity.reload.attributes }.to include(
        "access_token_valid" => true,
        "can_discover_pages" => true,
        "can_moderate_comments" => false,
        "access_status" => "partial"
      )
    end
  end

  context "when page_comments_manage permission is missing" do
    let(:permission_page_comments_manage) { false }

    it "reflects revoked access" do
      expect { refresh }.to change { identity.reload.attributes }.to include(
        "access_token_valid" => true,
        "can_discover_pages" => true,
        "can_moderate_comments" => false,
        "access_status" => "partial"
      )
    end
  end
end
