class CreateDeviceSessions < ActiveRecord::Migration
  def change
    create_table :device_sessions do |t|
      t.references :device, index: true
      t.string :ip, limit: 64
      t.string :xmpp_account, limit: 64

      t.timestamps
    end
  end
end
