# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.0].define(version: 2024_11_24_155134) do
  create_table "acme_integration_identities", force: :cascade do |t|
    t.integer "client_id", null: false
    t.string "acme_id", null: false
    t.string "name", null: false
    t.string "avatar_url", null: false
    t.string "access_token"
    t.boolean "access_token_valid", default: false, null: false
    t.boolean "can_discover_pages", default: false, null: false
    t.boolean "can_moderate_comments", default: false, null: false
    t.boolean "permission_public_profile_read", default: false, null: false
    t.boolean "permission_pages_read", default: false, null: false
    t.boolean "permission_page_comments_read", default: false, null: false
    t.boolean "permission_page_comments_manage", default: false, null: false
    t.integer "access_status", default: 0, null: false
    t.datetime "last_synced_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["client_id", "acme_id"], name: "index_acme_integration_identities_on_client_id_and_acme_id", unique: true
    t.index ["client_id"], name: "index_acme_integration_identities_on_client_id"
  end

  create_table "acme_integration_pages", force: :cascade do |t|
    t.integer "client_id", null: false
    t.integer "access_provider_id"
    t.string "public_id", null: false
    t.string "acme_id", null: false
    t.string "name"
    t.string "avatar_url"
    t.boolean "manager_role_granted", default: false, null: false
    t.boolean "discoverable", default: false, null: false
    t.integer "status", default: 0, null: false
    t.boolean "retrieve_comments", default: false, null: false
    t.datetime "last_synced_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["access_provider_id"], name: "index_acme_integration_pages_on_access_provider_id"
    t.index ["acme_id"], name: "index_acme_integration_pages_on_acme_id"
    t.index ["client_id", "acme_id"], name: "index_acme_integration_pages_on_client_id_and_acme_id", unique: true
    t.index ["public_id"], name: "index_acme_integration_pages_on_public_id", unique: true
  end

  create_table "clients", force: :cascade do |t|
    t.string "title"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "moderation_comment_feeds", force: :cascade do |t|
    t.integer "client_id", null: false
    t.integer "platform", null: false
    t.boolean "moderated", default: false, null: false
    t.string "public_id", null: false
    t.string "upstream_id", null: false
    t.string "title", null: false
    t.string "url"
    t.string "avatar_url"
    t.boolean "connected", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["client_id", "public_id"], name: "index_moderation_comment_feeds_on_client_id_and_public_id"
    t.index ["client_id"], name: "index_moderation_comment_feeds_on_client_id"
    t.index ["public_id"], name: "index_moderation_comment_feeds_on_public_id", unique: true
    t.index ["upstream_id"], name: "index_moderation_comment_feeds_on_upstream_id", unique: true, where: "moderated IS TRUE"
  end

  create_table "sessions", force: :cascade do |t|
    t.integer "user_id", null: false
    t.string "ip_address"
    t.string "user_agent"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_sessions_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email_address", null: false
    t.string "password_digest", null: false
    t.string "access_token", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "client_id"
    t.index ["client_id"], name: "index_users_on_client_id"
    t.index ["email_address"], name: "index_users_on_email_address", unique: true
  end

  add_foreign_key "sessions", "users"
end
