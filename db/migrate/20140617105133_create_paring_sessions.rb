class CreateParingSessions < ActiveRecord::Migration
  def change
    create_table :paring_sessions do |t|
      t.references :user, index: true, :null => false
      t.references :device, index: true, :null => false
      t.integer :status, :default => 0, :null => false
      t.datetime :exprie_at, :null => false

      t.timestamps
    end
  end
end
