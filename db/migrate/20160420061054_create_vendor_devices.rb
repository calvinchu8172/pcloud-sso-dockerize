class CreateVendorDevices < ActiveRecord::Migration
  def change
    create_table :vendor_devices do |t|
      t.integer :user_id,                              null: false
      t.string  :udid,                    limit:  40,  null: false
      t.integer :vendor_id,                            null: false
      t.integer :vendor_product_id,                    null: false
      t.string  :mac_address,             limit:  12
      t.integer :mac_range,               limit:   3
      t.string  :mac_address_secondary,   limit:  12
      t.integer :mac_range_secondary,     limit:   3
      t.string  :device_name,             limit:  40
      t.string  :firmware_version,        limit: 120,  null: false
      t.string  :serial_number,           limit: 100,  null: false
      t.string  :ipv4_lan,                limit:  15,  null: false
      t.string  :ipv6_lan,                limit:  32
      t.string  :ipv4_wan,                limit:  15
      t.string  :ipv4_lan_secondary,      limit:  15
      t.string  :ipv6_lan_secondary,      limit:  32
      t.string  :ipv4_wan_secondary,      limit:  15
      t.integer :online_status,           limit:   1,  null: false
      t.binary  :meta

      t.timestamps null: false
    end
  end
end
