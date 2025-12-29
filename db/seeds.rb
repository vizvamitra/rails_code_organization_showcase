# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

Client.delete_all
client = Client.create(title: "Example")

User.delete_all
user = client.users.create!(
  email_address: "client@example.com",
  password: "password",
  access_token: SecureRandom.hex(10)
)

AcmeIntegration::Identity.delete_all
identity = client.acme_identities.create!(
  external_id: "qwerty",
  name: "Jane Doe",
  access_token: SecureRandom.hex(10),
  avatar_url: "https://example.com/avatar.jpg",
  access_token_valid: true,
  can_discover_pages: true,
  can_moderate_comments: true,
  permission_public_profile_read: true,
  permission_pages_read: true,
  permission_page_comments_read: true,
  permission_page_comments_manage: true,
  access_status: :full,
  last_synced_at: 1.day.ago
)

AcmeIntegration::Page.delete_all
[ #              name |         status | manager | active | access_acquired
  [  "What was that?", :undiscoverable,    false,   false,           false],
  ["Not in this life",     :inoperable,    false,   false,           false],
  ["This one broken!",     :inoperable,    false,    true,           false],
  [    "You're good!",       :operable,     true,    true,            true]
].each do |name, status, manager_role_granted, active, access_acquired|
  page = client.acme_pages.create!(
    access_provider: identity,
    external_id: SecureRandom.hex(8),
    public_id: SecureRandom.uuid,
    name:,
    avatar_url: "https://i.pravatar.cc/150?u=#{name.gsub(/\s/, '+')}",
    status:,
    manager_role_granted:,
    last_synced_at: 1.day.ago
  )

  asset = client.moderation_assets.create!(
    source: :acme,
    active:,
    public_id: page.public_id,
    external_id: page.external_id,
    title: page.name,
    avatar_url: page.avatar_url,
    url: page.url,
    access_acquired:
  )
end
