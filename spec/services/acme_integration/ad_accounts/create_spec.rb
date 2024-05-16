require 'spec_helper'

describe AcmeIntegration::AdAccounts::Create do
  subject(:create) do
    described_class
      .new(fetch_identity:, search_ad_account:, ads_management:)
      .call(user_id:, access_token: 'whatever')
  end

  let(:fetch_identity) { instance_double(AcmeIntegration::Identities::Fetch) }
  let(:search_ad_account) do
    instance_double(AcmeIntegration::AdAccounts::SearchConnectable)
  end
  let(:ads_management) { instance_double(AdsManagement::Interface) }

  let!(:user) { create(:user) }

  let(:user_id) { user.id }
  let(:admin) { true }
  let(:identity_fetching_error) { nil }
  let(:identity_attrs) { build(:acme_integration_identity_attrs, admin:) }
  let(:ad_account_attrs) { build(:acme_integration_ad_account_attrs) }

  before do
    allow(fetch_identity).to receive(:call) do
      raise(identity_fetching_error) if identity_fetching_error

      identity_attrs
    end

    allow(search_ad_account).to receive(:call) { ad_account_attrs }
    allow(ads_management).to receive(:create_asset)
  end

  context 'when all preconditions are met' do
    it 'creates ad account, notifies ads management about new asset' do
      expect { create }.and change { account.acme_ad_accounts.count }.by(1)

      ad_account = account.acme_ad_accounts.first
      expect(ad_account).to have_attributes(
        external_id: ad_account_attrs.id,
        public_id: be_a(String),
        identity_external_id: identity_attrs.id,
        access_token: 'whatever',
        access_status: :acquired,
        name: ad_account_attrs.name,
        status: ad_account_attrs.status,
        ads_syncronization: false
      )

      expect(fetch_identity).to have_received(:call).with(access_token: 'whatever')
      expect(search_ad_account).to have_received(:call).with(access_token: 'whatever')
      expect(ads_management).to have_received(:create_asset).with(
        user_id:,
        source: 'acme',
        public_id: ad_account.public_id,
        name: ad_account.name
      )
    end
  end

  context 'when user does not exist' do
    let(:user_id) { 'invalid' }
    it { expect { create }.to raise_error(ActiveRecord::RecordNotFound) }
  end

  context 'when access token is invalid' do
    let(:identity_fetching_error) { AcmeIntegration::AccessTokenInvalidError }
    it { expect { create }.to raise_error(AcmeIntegration::AccessTokenInvalidError) }
  end

  context 'when some permission is missing' do
    let(:identity_fetching_error) { AcmeIntegration::PermissionMissingError }
    it { expect { create }.to raise_error(AcmeIntegration::PermissionMissingError) }
  end

  context 'when acme API call fails with a generic error' do
    let(:identity_fetching_error) { AcmeSDK::ServerError }
    it { expect { create }.to raise_error(AcmeSDK::ServerError) }
  end

  context 'when identity does not have admin role' do
    let(:admin) { false }
    it { expect { create }.to raise_error(AcmeIntegration::AdminRoleMissingError) }
  end

  context 'when ad account is missing' do
    let(:ad_account_attrs) { nil }
    it { expect { create }.to raise_error(AcmeIntegration::AdAccountMissingError) }
  end
end
