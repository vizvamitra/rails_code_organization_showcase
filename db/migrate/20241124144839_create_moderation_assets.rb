class CreateModerationAssets < ActiveRecord::Migration[8.0]
  def change
    create_table :moderation_assets do |t|
      t.references :client, null: false
      t.integer :source, null: false
      t.boolean :active, null: false, default: false

      # integration-controlled fields
      t.string :public_id, null: false
      t.string :external_id, null: false
      t.string :title, null: false
      t.string :url
      t.string :avatar_url
      t.boolean :access_acquired, null: false, default: false

      t.timestamps

      t.index :public_id, unique: true
      t.index %i[client_id public_id]
      t.index %i[external_id], unique: true, where: "active IS TRUE"
    end
  end
end
