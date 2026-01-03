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
  acme_id: "qwerty",
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
[ #              name |         status | manager | moderated | connected
  [  "What was that?", :undiscoverable,    false,      false,      false],
  ["Not in this life",     :inoperable,    false,      false,      false],
  ["This one broken!",     :inoperable,    false,       true,      false],
  [    "You're good!",       :operable,     true,       true,       true]
].each do |name, status, manager_role_granted, moderated, connected|
  page = client.acme_pages.create!(
    access_provider: identity,
    acme_id: SecureRandom.hex(8),
    public_id: SecureRandom.uuid,
    name:,
    avatar_url: "https://i.pravatar.cc/150?u=#{name.gsub(/\s/, '+')}",
    status:,
    manager_role_granted:,
    last_synced_at: 1.day.ago
  )

  client.moderation_comment_feeds.create!(
    platform: :acme,
    public_id: page.public_id,
    upstream_id: page.acme_id,
    title: page.name,
    url: page.url,
    avatar_url: page.avatar_url,
    moderated:,
    connected:
  )
end
