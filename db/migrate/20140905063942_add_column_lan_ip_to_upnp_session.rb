class AddColumnLanIpToUpnpSession < ActiveRecord::Migration
  def change
    add_column :upnp_sessions, :lan_ip, :string, limit: 20
  end
end
