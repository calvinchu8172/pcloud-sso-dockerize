class AddColumnToUser < ActiveRecord::Migration
  def change
    add_column :users, :middle_name, :string 
  end
end
