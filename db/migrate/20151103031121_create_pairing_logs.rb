class CreatePairingLogs < ActiveRecord::Migration
  def change
    create_table :pairing_logs do |t|
      t.integer :user_id
      t.integer :device_id
      t.string :ip_address
      t.string :status

      t.timestamps null: false
    end
  end
end
