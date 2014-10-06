class CreateDomain < ActiveRecord::Migration
  def up
    create_table :domains, option: "CHARSET=utf8 COLLATE=utf8_general_ci" do |t|
      t.string :domain_name, limit: 192, null: false
      t.timestamps
    end
    add_index :domains, [:domain_name], unique: true
  end
  def down
    drop_table :domains
  end
end
