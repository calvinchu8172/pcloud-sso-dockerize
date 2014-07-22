class AddCountryToUsers < ActiveRecord::Migration
  def change
    add_column :users, :country, :string, limit: 100, null:false
  end
end
