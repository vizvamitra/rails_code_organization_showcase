class CreateAcmeIntegrationIdentities < ActiveRecord::Migration[8.0]
  def change
    create_table :acme_integration_identities do |t|
      t.references :client, null: false
      t.string :external_id, null: false
      t.string :name, null: false
      t.string :avatar_url, null: false
      t.string :access_token
      t.boolean :access_token_valid, null: false, default: false
      t.boolean :can_view_public_profile, null: false, default: false
      t.boolean :can_moderate_comments, null: false, default: false
      t.boolean :permission_public_profile_read, null: false, default: false
      t.boolean :permission_pages_read, null: false, default: false
      t.boolean :permission_page_comments_read, null: false, default: false
      t.boolean :permission_page_comments_manage, null: false, default: false

      t.timestamps
    end
    add_index :acme_integration_identities, %i[client_id external_id], unique: true
  end
end
