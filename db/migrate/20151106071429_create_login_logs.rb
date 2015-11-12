class CreateLoginLogs < ActiveRecord::Migration
  def change
    create_table :login_logs do |t|
      t.integer :user_id
      t.datetime :sign_in_at
      t.datetime :sign_out_at
      t.datetime :sign_in_fail_at
      t.string :sign_in_ip
      t.string :os
      t.string :oauth

      t.timestamps null: false
    end
  end
end
