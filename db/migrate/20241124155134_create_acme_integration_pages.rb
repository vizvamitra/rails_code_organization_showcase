class CreateAcmeIntegrationPages < ActiveRecord::Migration[8.0]
  def change
    create_table :acme_integration_pages do |t|
      t.references :client, null: false
      t.references :identity, null: false
      t.string :external_id, null: false
      t.string :name, null: false
      t.string :avatar_url, null: false
      t.boolean :manager_role_granted, null: false, default: false
      t.boolean :discoverable, null: false, default: false
      t.integer :status, null: false, default: 0
      t.boolean :retrieve_comments, null: false, default: false

      t.timestamps
    end
    add_index :acme_integration_pages, %i[client_id external_id], unique: true
    add_index :acme_integration_pages, :external_id
  end
end
