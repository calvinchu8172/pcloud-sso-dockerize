class CreateLast < ActiveRecord::Migration
  def up
    create_table :last, id: false do |t|
      t.string  :username,       null: false, limit: 250
      t.integer :seconds,        null: false
      t.text    :state,          null: false
      t.integer :last_signin_at, null: false
    end
    execute "ALTER TABLE last ADD PRIMARY KEY (username);"
  end

  def down
    drop_table :last
  end
end
