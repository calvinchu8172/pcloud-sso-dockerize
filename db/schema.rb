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

ActiveRecord::Schema.define(version: 20170922080411) do

  create_table "accepted_users", force: :cascade do |t|
    t.integer  "invitation_id", limit: 4, null: false
    t.integer  "user_id",       limit: 4, null: false
    t.integer  "status",        limit: 1
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "accepted_users", ["invitation_id", "user_id"], name: "index_accepted_users_on_invitation_id_and_user_unique", unique: true, using: :btree
  add_index "accepted_users", ["invitation_id"], name: "index_accepted_users_on_invitation_id", using: :btree
  add_index "accepted_users", ["user_id"], name: "index_accepted_users_on_user_id", using: :btree

  create_table "categories", force: :cascade do |t|
    t.string   "name",       limit: 255, null: false
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  add_index "categories", ["name"], name: "index_categories_on_name", unique: true, using: :btree

  create_table "certificates", force: :cascade do |t|
    t.string   "serial",      limit: 255,   null: false
    t.text     "content",     limit: 65535, null: false
    t.integer  "vendor_id",   limit: 4
    t.string   "description", limit: 255
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
  end

  create_table "ddns", force: :cascade do |t|
    t.integer  "device_id",  limit: 4,  null: false
    t.string   "ip_address", limit: 8,  null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "domain_id",  limit: 4
    t.string   "hostname",   limit: 63, null: false
    t.integer  "status",     limit: 4
  end

  add_index "ddns", ["device_id"], name: "index_ddns_on_device_id_unique", unique: true, using: :btree
  add_index "ddns", ["domain_id"], name: "ddns_domain_id_fk", using: :btree
  add_index "ddns", ["hostname", "domain_id"], name: "index_ddns_on_hostname_and_domain_id_unique", unique: true, using: :btree

  create_table "devices", force: :cascade do |t|
    t.string   "serial_number",                  limit: 100,             null: false
    t.string   "mac_address",                    limit: 12,              null: false
    t.string   "firmware_version",               limit: 120,             null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "product_id",                     limit: 4,               null: false
    t.string   "ip_address",                     limit: 15
    t.integer  "online_status",                  limit: 1,   default: 0, null: false
    t.integer  "wol_status",                     limit: 1,   default: 0, null: false
    t.string   "mac_address_of_router_lan_port", limit: 25
    t.string   "country",                        limit: 3
  end

  add_index "devices", ["country"], name: "index_devices_on_country", using: :btree
  add_index "devices", ["mac_address", "serial_number"], name: "index_devices_on_mac_address_and_serial_number", unique: true, using: :btree
  add_index "devices", ["mac_address"], name: "index_devices_on_mac_address", using: :btree
  add_index "devices", ["product_id"], name: "devices_product_id_fk", using: :btree

  create_table "diagram_datapoints", force: :cascade do |t|
    t.string   "type",       limit: 255
    t.string   "value",      limit: 255
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  create_table "domains", force: :cascade do |t|
    t.string   "domain_name", limit: 192, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "domains", ["domain_name"], name: "index_domains_on_domain_name", unique: true, using: :btree

  create_table "identities", force: :cascade do |t|
    t.integer  "user_id",    limit: 4,   null: false
    t.string   "provider",   limit: 15,  null: false
    t.string   "uid",        limit: 255, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "identities", ["provider", "uid"], name: "index_identities_on_provider_and_uid", unique: true, using: :btree
  add_index "identities", ["user_id", "provider"], name: "index_identities_on_user_id_and_provider", unique: true, using: :btree

  create_table "invitations", force: :cascade do |t|
    t.string   "key",          limit: 255,             null: false
    t.string   "share_point",  limit: 255,             null: false
    t.integer  "permission",   limit: 1,   default: 0
    t.integer  "device_id",    limit: 4,               null: false
    t.integer  "expire_count", limit: 4,   default: 0
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "invitations", ["device_id"], name: "index_invitations_on_device_id", using: :btree

  create_table "login_logs", force: :cascade do |t|
    t.integer  "user_id",         limit: 4
    t.datetime "sign_in_at"
    t.datetime "sign_out_at"
    t.datetime "sign_in_fail_at"
    t.string   "sign_in_ip",      limit: 255
    t.string   "os",              limit: 255
    t.string   "oauth",           limit: 255
    t.datetime "created_at",                  null: false
    t.datetime "updated_at",                  null: false
  end

  add_index "login_logs", ["created_at"], name: "index_login_logs_on_created_at", using: :btree
  add_index "login_logs", ["oauth"], name: "index_login_logs_on_oauth", using: :btree
  add_index "login_logs", ["os"], name: "index_login_logs_on_os", using: :btree
  add_index "login_logs", ["sign_in_at"], name: "index_login_logs_on_sign_in_at", using: :btree
  add_index "login_logs", ["user_id"], name: "index_login_logs_on_user_id", using: :btree

  create_table "oauth_access_grants", force: :cascade do |t|
    t.integer  "resource_owner_id", limit: 4,     null: false
    t.integer  "application_id",    limit: 4,     null: false
    t.string   "token",             limit: 255,   null: false
    t.integer  "expires_in",        limit: 4,     null: false
    t.text     "redirect_uri",      limit: 65535, null: false
    t.datetime "created_at",                      null: false
    t.datetime "revoked_at"
    t.string   "scopes",            limit: 255
  end

  add_index "oauth_access_grants", ["token"], name: "index_oauth_access_grants_on_token", unique: true, using: :btree

  create_table "oauth_access_tokens", force: :cascade do |t|
    t.integer  "resource_owner_id", limit: 4
    t.integer  "application_id",    limit: 4
    t.string   "token",             limit: 255, null: false
    t.string   "refresh_token",     limit: 255
    t.integer  "expires_in",        limit: 4
    t.datetime "revoked_at"
    t.datetime "created_at",                    null: false
    t.string   "scopes",            limit: 255
  end

  add_index "oauth_access_tokens", ["refresh_token"], name: "index_oauth_access_tokens_on_refresh_token", unique: true, using: :btree
  add_index "oauth_access_tokens", ["resource_owner_id"], name: "index_oauth_access_tokens_on_resource_owner_id", using: :btree
  add_index "oauth_access_tokens", ["token"], name: "index_oauth_access_tokens_on_token", unique: true, using: :btree

  create_table "oauth_applications", force: :cascade do |t|
    t.string   "name",                limit: 255,                null: false
    t.string   "uid",                 limit: 255,                null: false
    t.string   "secret",              limit: 255,                null: false
    t.text     "redirect_uri",        limit: 65535
    t.string   "scopes",              limit: 255,   default: "", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "logout_redirect_uri", limit: 65535
  end

  add_index "oauth_applications", ["uid"], name: "index_oauth_applications_on_uid", unique: true, using: :btree

  create_table "pairing_logs", force: :cascade do |t|
    t.integer  "user_id",    limit: 4
    t.integer  "device_id",  limit: 4
    t.string   "ip_address", limit: 255
    t.string   "status",     limit: 255
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  add_index "pairing_logs", ["created_at"], name: "index_pairing_logs_on_created_at", using: :btree
  add_index "pairing_logs", ["device_id"], name: "index_pairing_logs_on_device_id", using: :btree
  add_index "pairing_logs", ["status"], name: "index_pairing_logs_on_status", using: :btree
  add_index "pairing_logs", ["user_id"], name: "index_pairing_logs_on_user_id", using: :btree

  create_table "pairings", force: :cascade do |t|
    t.integer  "user_id",    limit: 4, null: false
    t.integer  "device_id",  limit: 4, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "ownership",  limit: 1, null: false
  end

  add_index "pairings", ["device_id"], name: "index_pairings_on_device_id", using: :btree
  add_index "pairings", ["user_id", "device_id"], name: "index_pairings_on_user_id_and_device_id", unique: true, using: :btree

  create_table "products", force: :cascade do |t|
    t.string   "name",                 limit: 255, null: false
    t.string   "model_class_name",     limit: 120, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "asset_file_name",      limit: 255
    t.string   "asset_content_type",   limit: 255
    t.integer  "asset_file_size",      limit: 4
    t.datetime "asset_updated_at"
    t.string   "pairing_file_name",    limit: 255
    t.string   "pairing_content_type", limit: 255
    t.integer  "pairing_file_size",    limit: 4
    t.datetime "pairing_updated_at"
    t.boolean  "show"
    t.integer  "category_id",          limit: 4,   null: false
  end

  add_index "products", ["category_id"], name: "index_products_on_category_id", using: :btree
  add_index "products", ["model_class_name"], name: "index_products_on_model_class_name", unique: true, using: :btree

  create_table "template_contents", force: :cascade do |t|
    t.integer  "template_id", limit: 4,     null: false
    t.string   "locale",      limit: 255
    t.string   "title",       limit: 255
    t.text     "content",     limit: 65535
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
  end

  add_index "template_contents", ["locale"], name: "index_template_contents_on_locale", using: :btree
  add_index "template_contents", ["template_id"], name: "index_template_contents_on_template_id", using: :btree

  create_table "templates", force: :cascade do |t|
    t.string   "identity",   limit: 255, null: false
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  add_index "templates", ["identity"], name: "index_templates_on_identity", using: :btree

  create_table "users", force: :cascade do |t|
    t.string   "email",                  limit: 255, default: "",   null: false
    t.string   "encrypted_password",     limit: 60,  default: "",   null: false
    t.string   "reset_password_token",   limit: 255
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          limit: 4,   default: 0,    null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip",     limit: 255
    t.string   "last_sign_in_ip",        limit: 255
    t.string   "confirmation_token",     limit: 255
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "first_name",             limit: 255
    t.string   "last_name",              limit: 255
    t.boolean  "gender"
    t.string   "mobile_number",          limit: 40
    t.string   "unconfirmed_email",      limit: 255
    t.string   "language",               limit: 5,   default: "en", null: false
    t.datetime "birthday"
    t.boolean  "edm_accept"
    t.string   "country",                limit: 2
    t.string   "middle_name",            limit: 255
    t.string   "display_name",           limit: 255,                null: false
    t.string   "os",                     limit: 255
    t.string   "oauth",                  limit: 255
    t.datetime "revoked_at"
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree

  create_table "vendor_devices", force: :cascade do |t|
    t.integer  "user_id",               limit: 4,     null: false
    t.string   "udid",                  limit: 40,    null: false
    t.integer  "vendor_id",             limit: 4,     null: false
    t.integer  "vendor_product_id",     limit: 4,     null: false
    t.string   "mac_address",           limit: 12
    t.integer  "mac_range",             limit: 3
    t.string   "mac_address_secondary", limit: 12
    t.integer  "mac_range_secondary",   limit: 3
    t.string   "device_name",           limit: 40
    t.string   "firmware_version",      limit: 120,   null: false
    t.string   "serial_number",         limit: 100,   null: false
    t.string   "ipv4_lan",              limit: 15,    null: false
    t.string   "ipv6_lan",              limit: 32
    t.string   "ipv4_wan",              limit: 15
    t.string   "ipv4_lan_secondary",    limit: 15
    t.string   "ipv6_lan_secondary",    limit: 32
    t.string   "ipv4_wan_secondary",    limit: 15
    t.integer  "online_status",         limit: 1,     null: false
    t.binary   "meta",                  limit: 65535
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
  end

  create_table "vendor_products", force: :cascade do |t|
    t.integer  "vendor_id",          limit: 4,   null: false
    t.string   "product_class_name", limit: 20,  null: false
    t.string   "model_class_name",   limit: 255, null: false
    t.string   "asset_file_name",    limit: 255
    t.string   "asset_content_type", limit: 255
    t.integer  "asset_file_size",    limit: 4
    t.datetime "created_at",                     null: false
    t.datetime "updated_at",                     null: false
  end

  create_table "vendor_source_ips", force: :cascade do |t|
    t.integer  "vendor_id",  limit: 4,  null: false
    t.string   "ip_address", limit: 15, null: false
    t.datetime "created_at",            null: false
    t.datetime "updated_at",            null: false
  end

  create_table "vendors", force: :cascade do |t|
    t.string   "name",       limit: 20, null: false
    t.datetime "created_at",            null: false
    t.datetime "updated_at",            null: false
  end

  add_foreign_key "accepted_users", "invitations", name: "accepted_users_invitation_id_fk"
  add_foreign_key "accepted_users", "users", name: "accepted_users_user_id_fk"
  add_foreign_key "ddns", "devices", name: "ddns_device_id_fk"
  add_foreign_key "ddns", "domains", name: "ddns_domain_id_fk"
  add_foreign_key "devices", "products", name: "devices_product_id_fk"
  add_foreign_key "identities", "users", name: "identities_user_id_fk"
  add_foreign_key "invitations", "devices", name: "invitations_device_id_fk"
  add_foreign_key "pairings", "devices", name: "pairings_device_id_fk"
  add_foreign_key "pairings", "users", name: "pairings_user_id_fk"
end
