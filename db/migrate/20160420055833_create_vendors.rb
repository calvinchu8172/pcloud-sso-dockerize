class CreateVendors < ActiveRecord::Migration
  def change
    create_table :vendors do |t|
      t.string  :name, limit: 20, null: false

      t.timestamps null: false
    end
  end
end
