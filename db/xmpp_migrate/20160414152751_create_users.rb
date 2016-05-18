class CreateUsers < ActiveRecord::Migration
  def up
    create_table :users, id: false do |t|
      t.string :username,    null: false, limit: 250
      t.text   :password,    null: false
      t.text   :pass_details
      t.column :created_at, 'TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP'
    end
    execute 'ALTER TABLE users ADD PRIMARY KEY (username);'
  end

  def down
    drop_table :users
  end
end
