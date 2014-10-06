class CreateDevices < ActiveRecord::Migration
  def up
    create_table :devices, option: "CHARSET=utf8 COLLATE=utf8_general_ci" do |t|
      t.string :serical_number, limit: 100
      t.string :mac_address, limit: 100
      t.string :model_name, limit: 120
      t.string :fireware_version, limit: 120

      t.timestamps
    end
    add_index :devices, [:serical_number, :mac_address]
  end
  def down
  	drop_table :devices
  end
end
