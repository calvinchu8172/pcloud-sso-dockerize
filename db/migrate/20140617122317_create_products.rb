class CreateProducts < ActiveRecord::Migration
  def change
    create_table :products do |t|
      t.string :name
      t.string :model_name, limit: 120

      t.timestamps
    end
  end
end
