require 'spec_helper'

describe MyIntegration::Identities::ValidateCreate do
  subject(:validate) do
    described_class
      .new(fetch_identity: fetch_identity, search_asset: search_asset)
      .call(account_id: account_id, external_id: '123', access_token: 'whatever')
  end

  let(:fetch_identity) { instance_double(MyIntegration::Identities::Fetch) }
  let(:search_asset) { instance_double(MyIntegration::Assets::SearchOperable) }

  let(:account) { create(:account) }
  let(:account_id) { account.id }

  let(:fetch_identity_result) do
    -> { build(:my_integration_identity_attributes, :admin) }
  end
  let(:search_asset_result) do
    -> { build(:my_integration_asset_attributes) }
  end

  before do
    allow(fetch_identity).to receive(:call).with(
      external_id: '123',
      access_token: 'whatever'
    ) { fetch_identity_result.call }

    allow(search_asset).to receive(:call).with(
      identity_id: '123',
      access_token: 'whatever'
    ) { search_asset_result.call }
  end

  context 'when all preconditions are met' do
    it { is_expected.to be_success }
  end

  context 'when account does not exist' do
    let(:account_id) { 'invalid' }
    it { expect { validate }.to raise_error(ActiveRecord::RecordNotFound) }
  end

  context 'when access token is invalid' do
    let(:fetch_identity_result) { -> { raise MyIntegration::AccessTokenInvalidError } }
    it { is_expected.to be_failure_of(:access_token_invalid) }
  end

  context 'when some permission is missing' do
    let(:fetch_identity_result) { -> { raise MyIntegration::PermissionMissingError } }
    it { is_expected.to be_failure_of(:permission_missing) }
  end

  context 'when identity can not be found' do
    let(:fetch_identity_result) { -> { raise MyIntegration::IdentityNotFoundError } }
    it { is_expected.to be_failure_of(:identity_not_found) }
  end

  context 'when identity does not have admin role' do
    let(:fetch_identity_result) do
      -> { build(:my_integration_identity_attributes, admin: false) }
    end

    it { is_expected.to be_failure_of(:admin_role_missing) }
  end

  context 'when asset is missing' do
    let(:search_asset_result) { -> { nil } }
    it { is_expected.to be_failure_of(:asset_missing) }
  end
end
