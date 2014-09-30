class CheangeColumnValidateOnProduct < ActiveRecord::Migration
  def change
    change_column :products, :name,       :string, null: false
    change_column :products, :model_name, :string, null: false, limit: 120

    add_index     :products, :model_name, unique: true
  end
end
