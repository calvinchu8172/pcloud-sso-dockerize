class AddColumnToDeviceSession < ActiveRecord::Migration
  def up
    add_column :device_sessions, :password, :string, limit: 60
  end

  def down
  	remove_column :device_sessions, :password
  end
end
