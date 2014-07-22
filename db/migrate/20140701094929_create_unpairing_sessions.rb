class CreateUnpairingSessions < ActiveRecord::Migration
  def change
    create_table :unpairing_sessions do |t|
      t.references :device, index: true

      t.timestamps
    end
  end
end
