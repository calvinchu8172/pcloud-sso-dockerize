class FixDeviceFirmwareVersionColumnName < ActiveRecord::Migration
	
  def up
  	rename_column :devices, :fireware_version, :firmware_version
  end

  def down
  	rename_column :devices, :firmware_version, :fireware_version
  end
end
