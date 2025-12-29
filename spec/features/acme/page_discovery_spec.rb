require "rails_helper"

RSpec.describe "Acme page discovery", type: :feature, jobs: :inline do
  let(:client) { create(:client) }
  let(:user) { create(:user, client:, password: '12345678') }

  let(:acme_token) { build(:acme_access_token) }
  let(:acme_identity) { build(:acme_api_identity) }
  let(:acme_api_page) { build(:acme_api_page) }

  before { login(user, '12345678') }

  scenario "page discovery" do
    given_clients_acme_user_has_access_to_one_acme_page

    when_the_client_authorizes_acme_user
    then_the_page_should_be_operable
    and_the_corresponding_asset_should_appear_as_accessible

    when_clients_acme_user_looses_manager_role_over_the_page
    and_asset_discovery_happens
    then_the_page_should_be_inoperable
    and_the_corresponding_asset_should_appear_as_not_accessible

    when_clients_acme_user_looses_access_to_the_page
    and_asset_discovery_happens
    then_the_page_should_be_undiscoverable
    and_the_corresponding_asset_should_appear_as_not_accessible

    when_clients_acme_user_regains_access_to_the_page
    and_asset_discovery_happens
    then_the_page_should_be_operable
    and_the_corresponding_asset_should_appear_as_accessible

    when_the_page_changes_name_and_avatar
    and_asset_discovery_happens
    then_the_page_should_be_updated_accordingly
    then_the_corresponding_asset_should_be_updated_accordingly
  end

  def given_clients_acme_user_has_access_to_one_acme_page
    stub_acme_identity(acme_token, acme_identity)
    stub_acme_pages(acme_token, [acme_api_page])
  end

  def when_the_client_authorizes_acme_user
    response = create_acme_identity(acme_token)
    expect(last_response.status).to eq(201)
    expect(response).to include('external_id' => acme_identity['id'])

    @acme_identity = response
  end

  def then_the_page_should_be_operable
    pages = get_acme_pages
    expect(pages.size).to eq(1)

    expect(pages.first).to include(
      'external_id' => acme_api_page['id'],
      'status' => 'operable'
    )

    @acme_page = pages.first
  end

  def and_the_corresponding_asset_should_appear_as_accessible
    assets = get_moderation_assets
    expect(assets.size).to eq(1)

    expect(assets.first).to include(
      'public_id' => @acme_page['public_id'],
      'access_acquired' => true
    )

    @asset = assets.first
  end

  def when_clients_acme_user_looses_manager_role_over_the_page
    acme_api_page['roles'] = ['viewer']
    stub_acme_pages(acme_token, [acme_api_page])
  end

  def and_asset_discovery_happens
    AcmeIntegration::SchedulePagesDiscoveryJob.perform_later
  end

  def then_the_page_should_be_inoperable
    pages = get_acme_pages
    expect(pages.size).to eq(1)

    expect(pages.first).to include(
      'external_id' => acme_api_page['id'],
      'status' => 'inoperable'
    )

    @acme_page = pages.first
  end

  def and_the_corresponding_asset_should_appear_as_not_accessible
    assets = get_moderation_assets
    expect(assets.size).to eq(1)

    expect(assets.first).to include(
      'public_id' => @acme_page['public_id'],
      'access_acquired' => false
    )

    @asset = assets.first
  end

  def when_clients_acme_user_looses_access_to_the_page
    stub_acme_pages(acme_token, [])
  end

  def then_the_page_should_be_undiscoverable
    pages = get_acme_pages
    expect(pages.size).to eq(1)

    expect(pages.first).to include(
      'external_id' => acme_api_page['id'],
      'status' => 'undiscoverable'
    )

    @acme_page = pages.first
  end

  def when_clients_acme_user_regains_access_to_the_page
    acme_api_page['roles'] = ['viewer', 'manager']
    stub_acme_pages(acme_token, [acme_api_page])
  end

  def when_the_page_changes_name_and_avatar
    acme_api_page['name'] = 'Testing'
    acme_api_page['avatar_url'] = 'https://example.com/testing.png'
    stub_acme_pages(acme_token, [acme_api_page])
  end

  def then_the_page_should_be_updated_accordingly
    pages = get_acme_pages
    expect(pages.size).to eq(1)

    expect(pages.first).to include(
      'external_id' => acme_api_page['id'],
      'name' => 'Testing',
      'avatar_url' => 'https://example.com/testing.png'
    )

    @acme_page = pages.first
  end

  def then_the_corresponding_asset_should_be_updated_accordingly
    assets = get_moderation_assets
    expect(assets.size).to eq(1)

    expect(assets.first).to include(
      'public_id' => @acme_page['public_id'],
      'title' => 'Testing',
      'avatar_url' => 'https://example.com/testing.png'
    )

    @asset = assets.first
  end
end
