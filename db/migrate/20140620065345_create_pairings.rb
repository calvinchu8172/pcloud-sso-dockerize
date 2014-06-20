class CreatePairings < ActiveRecord::Migration
  def change
    create_table :pairings do |t|
      t.references :user, index: true
      t.references :device, index: true

      t.timestamps
    end
  end
end
