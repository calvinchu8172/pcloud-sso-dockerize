class AddCountryToDevices < ActiveRecord::Migration
  def change
  	add_column :devices, :country, "char(3)"
  	add_index :devices, :country
  end
end
