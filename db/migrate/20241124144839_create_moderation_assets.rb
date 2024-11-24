class CreateModerationAssets < ActiveRecord::Migration[8.0]
  def change
    create_table :moderation_assets do |t|
      t.references :client, null: false
      t.integer :source, null: false
      t.integer :public_id, null: false
      t.string :title, null: false
      t.string :avatar_url, null: false
      t.string :external_id, null: false
      t.boolean :moderated, null: false, default: false
      t.boolean :access_acquired, null: false, default: false

      t.timestamps
    end
    add_index :moderation_assets, :public_id, unique: true
    add_index :moderation_assets, %i[client_id external_id], unique: true
  end
end
