class CreateVendorDevices < ActiveRecord::Migration
  def change
    create_table :vendor_devices do |t|
      t.integer :user_id,                              null: false
      t.string  :udid,                    limit:  20,  null: false
      t.integer :vendor_id,                            null: false
      t.string  :mac_address,             limit:  12
      t.string  :mac_address_secondary,   limit:  12
      t.string  :model_class_name,        limit: 120,  null: false
      t.string  :product_class_name,      limit:  20,  null: false
      t.string  :device_name,             limit:  40
      t.string  :firmware_version,        limit: 120,  null: false
      t.string  :serial_number,           limit: 100,  null: false
      t.string  :ip_address,              limit:  15,  null: false
      t.string  :ip_address_secondary,    limit:  15
      t.integer :online_status,           limit:   1,  null: false
      t.binary  :meta

      t.timestamps null: false
    end
  end
end
