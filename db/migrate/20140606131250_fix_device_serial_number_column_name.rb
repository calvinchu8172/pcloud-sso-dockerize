class FixDeviceSerialNumberColumnName < ActiveRecord::Migration
	
  def up
  	rename_column :devices, :serical_number, :serial_number
  end

  def down
  	rename_column :devices, :serial_number, :serical_number
  end
end
