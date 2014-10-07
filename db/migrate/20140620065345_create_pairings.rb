class CreatePairings < ActiveRecord::Migration
  def change
    create_table :pairings, option: "CHARSET=utf8 COLLATE=utf8_general_ci" do |t|
      t.references :user, index: true
      t.references :device, index: true

      t.timestamps
    end
  end
end
