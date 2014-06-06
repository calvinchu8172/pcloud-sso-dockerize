class CreateDeviceSessions < ActiveRecord::Migration
  def up
    create_table :device_sessions do |t|
      t.references :device, index: true
      t.string :ip, limit: 64
      t.string :xmpp_account, limit: 64

      t.timestamps
    end
  end

  def down
  	drop_table :device_sessions
  end
end
