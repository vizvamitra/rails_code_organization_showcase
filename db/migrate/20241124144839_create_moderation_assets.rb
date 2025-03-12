class CreateModerationAssets < ActiveRecord::Migration[8.0]
  def change
    create_table :moderation_assets do |t|
      t.references :client, null: false
      t.integer :source, null: false
      t.string :public_id, null: false
      t.string :title
      t.string :avatar_url
      t.string :url
      t.boolean :moderated, null: false, default: false
      t.boolean :access_acquired, null: false, default: false

      t.timestamps

      t.index :public_id, unique: true
      t.index %i[client_id public_id]
    end
  end
end
