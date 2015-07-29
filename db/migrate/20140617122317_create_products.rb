class CreateProducts < ActiveRecord::Migration
  def change
    create_table :products, option: "CHARSET=utf8 COLLATE=utf8_general_ci" do |t|
      t.string :name
      t.string :model_class_name, limit: 120, unique:true, index: true

      t.timestamps
    end
  end

end
