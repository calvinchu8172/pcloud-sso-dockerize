class AddShowColumnAndCategoryIdToProducts < ActiveRecord::Migration
  def change
    add_column :products, :show, :boolean, default: nil
    add_reference :products, :category, index: true, null: false
  end
end
