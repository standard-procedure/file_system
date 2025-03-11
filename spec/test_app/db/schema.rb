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

ActiveRecord::Schema[8.0].define(version: 2025_03_12_100000) do
  create_table "action_text_rich_texts", force: :cascade do |t|
    t.string "name", null: false
    t.text "body"
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["record_type", "record_id", "name"], name: "index_action_text_rich_texts_uniqueness", unique: true
  end

  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.string "service_name", null: false
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "documents", force: :cascade do |t|
    t.string "title", null: false
    t.text "content", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "file_system_comments", force: :cascade do |t|
    t.integer "item_revision_id"
    t.string "creator_type"
    t.integer "creator_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["creator_type", "creator_id"], name: "index_file_system_comments_on_creator"
    t.index ["item_revision_id"], name: "index_file_system_comments_on_item_revision_id"
  end

  create_table "file_system_folders", force: :cascade do |t|
    t.integer "volume_id"
    t.integer "parent_id"
    t.string "name", default: "", null: false
    t.integer "status", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["parent_id"], name: "index_file_system_folders_on_parent_id"
    t.index ["volume_id", "parent_id", "status", "name"], name: "idx_on_volume_id_parent_id_status_name_eb6d58b8ec", unique: true
    t.index ["volume_id"], name: "index_file_system_folders_on_volume_id"
  end

  create_table "file_system_folders_items", id: false, force: :cascade do |t|
    t.integer "file_system_folder_id", null: false
    t.integer "file_system_item_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["file_system_folder_id", "file_system_item_id"], name: "index_folders_items_on_folder_id_and_item_id", unique: true
    t.index ["file_system_item_id", "file_system_folder_id"], name: "index_folders_items_on_item_id_and_folder_id"
  end

  create_table "file_system_item_revisions", force: :cascade do |t|
    t.integer "item_id"
    t.string "creator_type"
    t.integer "creator_id"
    t.string "contents_type"
    t.integer "contents_id"
    t.string "name", default: "", null: false
    t.integer "number", null: false
    t.text "metadata"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["contents_type", "contents_id"], name: "index_file_system_item_revisions_on_contents"
    t.index ["creator_type", "creator_id"], name: "index_file_system_item_revisions_on_creator"
    t.index ["item_id"], name: "index_file_system_item_revisions_on_item_id"
  end

  create_table "file_system_items", force: :cascade do |t|
    t.integer "volume_id"
    t.integer "status", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["volume_id"], name: "index_file_system_items_on_volume_id"
  end

  create_table "file_system_volumes", force: :cascade do |t|
    t.string "name", default: "", null: false
    t.integer "status", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_file_system_volumes_on_name", unique: true
  end

  create_table "users", force: :cascade do |t|
    t.string "name", null: false
    t.string "email"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "file_system_comments", "file_system_item_revisions", column: "item_revision_id"
  add_foreign_key "file_system_folders", "file_system_folders", column: "parent_id"
  add_foreign_key "file_system_folders", "file_system_volumes", column: "volume_id"
  add_foreign_key "file_system_folders_items", "file_system_folders"
  add_foreign_key "file_system_folders_items", "file_system_items"
  add_foreign_key "file_system_item_revisions", "file_system_items", column: "item_id"
  add_foreign_key "file_system_items", "file_system_volumes", column: "volume_id"
end
