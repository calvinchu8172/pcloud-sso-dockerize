class AddMacAddressOfRouterLanPortToDevice < ActiveRecord::Migration
  def up
    add_column :devices, :mac_address_of_router_lan_port, :string, limit: 25, null: true
  end

  def down
    remove_column :devices, :mac_address_of_router_lan_port
  end
end
