class ChangeProductsModelNameToModelClassName < ActiveRecord::Migration
  def up
    rename_column :products, :model_name, :model_class_name
  end

  def down
    rename_column :products, :model_class_name, :model_name
  end
end
