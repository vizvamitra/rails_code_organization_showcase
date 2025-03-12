class CreateAcmeIntegrationPages < ActiveRecord::Migration[8.0]
  def change
    create_table :acme_integration_pages do |t|
      t.references :client, null: false, index: false
      t.references :access_provider
      t.string :public_id, null: false
      t.string :external_id, null: false
      t.string :name
      t.string :avatar_url
      t.boolean :manager_role_granted, null: false, default: false
      t.boolean :discoverable, null: false, default: false
      t.integer :status, null: false, default: 0
      t.boolean :retrieve_comments, null: false, default: false
      t.datetime :last_synced_at

      t.timestamps

      t.index %i[client_id external_id], unique: true
      t.index :external_id
      t.index :public_id, unique: true
    end
  end
end
