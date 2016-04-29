class CreateVendorProducts < ActiveRecord::Migration
  def change
    create_table :vendor_products do |t|
      t.integer :vendor_id,                     null: false
      t.string  :product_class_name, limit: 20, null: false
      t.string  :model_class_name,              null: false
      t.string  :asset_file_name
      t.string  :asset_content_type
      t.integer :asset_file_size

      t.timestamps null: false
    end
  end
end
