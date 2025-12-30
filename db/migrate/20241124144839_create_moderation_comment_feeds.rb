class CreateModerationCommentFeeds < ActiveRecord::Migration[8.0]
  def change
    create_table :moderation_comment_feeds do |t|
      t.references :client, null: false
      t.integer :platform, null: false
      t.boolean :moderated, null: false, default: false

      # integration-controlled fields
      t.string :public_id, null: false
      t.string :upstream_id, null: false
      t.string :title, null: false
      t.string :url
      t.string :avatar_url
      t.boolean :connected, null: false, default: false

      t.timestamps

      t.index :public_id, unique: true
      t.index %i[client_id public_id]
      t.index %i[upstream_id], unique: true, where: "moderated IS TRUE"
    end
  end
end
