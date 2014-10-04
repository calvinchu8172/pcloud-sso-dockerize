class DropSessionTable < ActiveRecord::Migration
  def change
    drop_table :ddns_retry_sessions
    drop_table :ddns_sessions
    drop_table :device_sessions
    drop_table :pairing_sessions
    drop_table :unpairing_sessions
    drop_table :upnp_sessions
  end
end
