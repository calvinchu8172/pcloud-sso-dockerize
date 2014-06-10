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

ActiveRecord::Schema.define(version: 20140609163305) do

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
    t.string   "mac_address",      limit: 100
    t.string   "model_name",       limit: 120
    t.string   "firmware_version", limit: 120
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "devices", ["serial_number", "mac_address"], name: "index_devices_on_serial_number_and_mac_address", using: :btree

end
