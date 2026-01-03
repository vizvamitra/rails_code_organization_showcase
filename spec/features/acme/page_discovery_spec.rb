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
    and_the_corresponding_comment_feed_should_appear_as_connected

    when_clients_acme_user_loses_manager_role_over_the_page
    and_page_discovery_happens
    then_the_page_should_be_inoperable
    and_the_corresponding_comment_feed_should_appear_as_disconnected

    when_clients_acme_user_loses_access_to_the_page
    and_page_discovery_happens
    then_the_page_should_be_undiscoverable
    and_the_corresponding_comment_feed_should_appear_as_disconnected

    when_clients_acme_user_regains_access_to_the_page
    and_page_discovery_happens
    then_the_page_should_be_operable
    and_the_corresponding_comment_feed_should_appear_as_connected

    when_the_page_changes_name_and_avatar
    and_page_discovery_happens
    then_the_page_should_be_updated_accordingly
    then_the_corresponding_comment_feed_should_be_updated_accordingly
  end

  def given_clients_acme_user_has_access_to_one_acme_page
    stub_acme_identity(acme_token, acme_identity)
    stub_acme_pages(acme_token, [acme_api_page])
  end

  def when_the_client_authorizes_acme_user
    response = create_acme_identity(acme_token)
    expect(last_response.status).to eq(201)
    expect(response).to include('acme_id' => acme_identity['id'])

    @acme_identity = response
  end

  def then_the_page_should_be_operable
    pages = get_acme_pages
    expect(pages.size).to eq(1)

    expect(pages.first).to include(
      'acme_id' => acme_api_page['id'],
      'status' => 'operable'
    )

    @acme_page = pages.first
  end

  def and_the_corresponding_comment_feed_should_appear_as_connected
    comment_feeds = get_moderation_comment_feeds
    expect(comment_feeds.size).to eq(1)

    expect(comment_feeds.first).to include(
      'public_id' => @acme_page['public_id'],
      'connected' => true
    )

    @comment_feed = comment_feeds.first
  end

  def when_clients_acme_user_loses_manager_role_over_the_page
    acme_api_page['roles'] = ['viewer']
    stub_acme_pages(acme_token, [acme_api_page])
  end

  def and_page_discovery_happens
    AcmeIntegration::SchedulePagesDiscoveryJob.perform_later
  end

  def then_the_page_should_be_inoperable
    pages = get_acme_pages
    expect(pages.size).to eq(1)

    expect(pages.first).to include(
      'acme_id' => acme_api_page['id'],
      'status' => 'inoperable'
    )

    @acme_page = pages.first
  end

  def and_the_corresponding_comment_feed_should_appear_as_disconnected
    comment_feeds = get_moderation_comment_feeds
    expect(comment_feeds.size).to eq(1)

    expect(comment_feeds.first).to include(
      'public_id' => @acme_page['public_id'],
      'connected' => false
    )

    @comment_feed = comment_feeds.first
  end

  def when_clients_acme_user_loses_access_to_the_page
    stub_acme_pages(acme_token, [])
  end

  def then_the_page_should_be_undiscoverable
    pages = get_acme_pages
    expect(pages.size).to eq(1)

    expect(pages.first).to include(
      'acme_id' => acme_api_page['id'],
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
      'acme_id' => acme_api_page['id'],
      'name' => 'Testing',
      'avatar_url' => 'https://example.com/testing.png'
    )

    @acme_page = pages.first
  end

  def then_the_corresponding_comment_feed_should_be_updated_accordingly
    comment_feeds = get_moderation_comment_feeds
    expect(comment_feeds.size).to eq(1)

    expect(comment_feeds.first).to include(
      'public_id' => @acme_page['public_id'],
      'title' => 'Testing',
      'avatar_url' => 'https://example.com/testing.png'
    )

    @comment_feed = comment_feeds.first
  end
end
