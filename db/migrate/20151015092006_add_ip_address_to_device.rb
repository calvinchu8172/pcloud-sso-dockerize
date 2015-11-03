class AddIpAddressToDevice < ActiveRecord::Migration
  def change
    add_column :devices, :ip_address, :string, limit: 15
  end
end
