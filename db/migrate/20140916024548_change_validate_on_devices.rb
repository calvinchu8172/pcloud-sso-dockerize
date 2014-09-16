class ChangeValidateOnDevices < ActiveRecord::Migration
  def change
    add_reference :devices, :product,       index: true, null: false

    remove_column :devices, :model_name
    remove_index  :devices, name: "index_devices_on_serial_number_and_mac_address"

    change_column :devices, :mac_address,   "char(12)",             null: false
    change_column :devices, :serial_number, :string,    limit: 100, null: false

    add_index     :devices, [:mac_address, :serial_number], unique: true
  end
end
