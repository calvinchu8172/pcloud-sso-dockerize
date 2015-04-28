class AddMacAddressIndexToDevices < ActiveRecord::Migration
  def change
    add_index :devices, :mac_address
  end
end
