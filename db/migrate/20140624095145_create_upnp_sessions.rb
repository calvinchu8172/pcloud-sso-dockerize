class CreateUpnpSessions < ActiveRecord::Migration
  def change
    create_table :upnp_sessions do |t|
      t.references :user, index: true
      t.references :device, index: true
      t.integer :status, :default => 0, :null => false
      t.text :service_list

      t.timestamps
    end
  end
end
