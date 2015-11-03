class CreatePairingLogs < ActiveRecord::Migration
  def change
    create_table :pairing_logs do |t|

      t.timestamps null: false
    end
  end
end
