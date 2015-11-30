class AddIndexOnPairinglogAndLoginlog < ActiveRecord::Migration
  def change
    add_index :pairing_logs, :user_id
    add_index :pairing_logs, :device_id
    add_index :pairing_logs, :status
    add_index :pairing_logs, :created_at
    add_index :login_logs, :user_id
    add_index :login_logs, :sign_in_at
    add_index :login_logs, :os
    add_index :login_logs, :oauth
    add_index :login_logs, :created_at
  end
end
