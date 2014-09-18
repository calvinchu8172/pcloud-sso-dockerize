# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20140917094430) do

  create_table "ddns", force: true do |t|
    t.integer  "device_id",             null: false
    t.string   "ip_address", limit: 8
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "domain_id"
    t.string   "hostname",   limit: 63
  end

  add_index "ddns", ["device_id"], name: "index_ddns_on_device_id", using: :btree
  add_index "ddns", ["device_id"], name: "index_domains_on_domain_name_unique", unique: true, using: :btree
  add_index "ddns", ["domain_id"], name: "ddns_domain_id_fk", using: :btree
  add_index "ddns", ["hostname", "domain_id"], name: "index_ddns_on_hostname_and_domain_id", unique: true, using: :btree

  create_table "ddns_retry_sessions", force: true do |t|
    t.integer  "device_id",                 null: false
    t.string   "full_domain", default: "0", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "ddns_retry_sessions", ["device_id"], name: "index_ddns_retry_sessions_on_device_id", using: :btree

  create_table "ddns_sessions", force: true do |t|
    t.integer  "device_id"
    t.string   "full_domain", limit: 100,             null: false
    t.integer  "status",                  default: 0, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "ddns_sessions", ["device_id"], name: "index_ddns_sessions_on_device_id", using: :btree

  create_table "device_sessions", force: true do |t|
    t.integer  "device_id"
    t.string   "ip",           limit: 64
    t.string   "xmpp_account", limit: 64
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "password",     limit: 60
  end

  add_index "device_sessions", ["device_id"], name: "index_device_sessions_on_device_id", using: :btree

  create_table "devices", force: true do |t|
    t.string   "serial_number",    limit: 100
    t.string   "mac_address",      limit: 12
    t.string   "firmware_version", limit: 120
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "product_id",                   null: false
  end

  add_index "devices", ["mac_address", "serial_number"], name: "index_devices_on_mac_address_and_serial_number", unique: true, using: :btree
  add_index "devices", ["product_id"], name: "devices_product_id_fk", using: :btree

  create_table "domains", force: true do |t|
    t.string   "domain_name", limit: 192
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "domains", ["domain_name"], name: "index_domains_on_domain_name", unique: true, using: :btree

  create_table "identities", force: true do |t|
    t.integer  "user_id",               null: false
    t.string   "provider",   limit: 15, null: false
    t.string   "uid",                   null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "identities", ["provider", "uid"], name: "index_identities_on_provider_and_uid", unique: true, using: :btree
  add_index "identities", ["user_id", "provider"], name: "index_identities_on_user_id_and_provider", unique: true, using: :btree

  create_table "pairing_sessions", force: true do |t|
    t.integer  "user_id",                null: false
    t.integer  "device_id",              null: false
    t.integer  "status",     default: 0, null: false
    t.datetime "expire_at",              null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "pairing_sessions", ["device_id"], name: "index_pairing_sessions_on_device_id", using: :btree
  add_index "pairing_sessions", ["user_id"], name: "index_pairing_sessions_on_user_id", using: :btree

  create_table "pairings", force: true do |t|
    t.integer  "user_id",              null: false
    t.integer  "device_id",            null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "ownership",  limit: 1, null: false
  end

  add_index "pairings", ["device_id"], name: "index_pairings_on_device_id", using: :btree
  add_index "pairings", ["user_id", "device_id"], name: "index_pairings_on_user_id_and_device_id", unique: true, using: :btree

  create_table "products", force: true do |t|
    t.string   "name",                             null: false
    t.string   "model_name",           limit: 120, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "asset_file_name"
    t.string   "asset_content_type"
    t.integer  "asset_file_size"
    t.datetime "asset_updated_at"
    t.string   "pairing_file_name"
    t.string   "pairing_content_type"
    t.integer  "pairing_file_size"
    t.datetime "pairing_updated_at"
  end

  add_index "products", ["model_name"], name: "index_products_on_model_name", unique: true, using: :btree

  create_table "unpairing_sessions", force: true do |t|
    t.integer  "device_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "unpairing_sessions", ["device_id"], name: "index_unpairing_sessions_on_device_id", using: :btree

  create_table "upnp_sessions", force: true do |t|
    t.integer  "user_id"
    t.integer  "device_id"
    t.integer  "status",                  default: 0, null: false
    t.text     "service_list"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "lan_ip",       limit: 20
  end

  add_index "upnp_sessions", ["device_id"], name: "index_upnp_sessions_on_device_id", using: :btree
  add_index "upnp_sessions", ["user_id"], name: "index_upnp_sessions_on_user_id", using: :btree

  create_table "users", force: true do |t|
    t.string   "email"
    t.string   "encrypted_password",     limit: 60
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",                     default: 0,    null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.string   "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "first_name"
    t.string   "last_name"
    t.boolean  "gender"
    t.string   "mobile_number",          limit: 40
    t.string   "unconfirmed_email"
    t.string   "language",               limit: 5,  default: "en", null: false
    t.datetime "birthday"
    t.boolean  "edm_accept"
    t.string   "country",                limit: 2
    t.string   "middle_name"
    t.string   "display_name",                                     null: false
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree

  add_foreign_key "ddns", "devices", name: "ddns_device_id_fk"
  add_foreign_key "ddns", "domains", name: "ddns_domain_id_fk"

  add_foreign_key "devices", "products", name: "devices_product_id_fk"

  add_foreign_key "identities", "users", name: "identities_user_id_fk"

  add_foreign_key "pairings", "devices", name: "pairings_device_id_fk"
  add_foreign_key "pairings", "users", name: "pairings_user_id_fk"

end
