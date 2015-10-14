class CreateProducts < ActiveRecord::Migration
  def change
    create_table :products, option: "CHARSET=utf8 COLLATE=utf8_general_ci" do |t|
      t.string :name, null: false
      t.string :model_class_name, limit: 120, null: false

      t.timestamps
    end
    add_index :products, :model_class_name, unique: true
  end

end
