class AddColumnToUsers < ActiveRecord::Migration
  def change
    add_column :users, :first_name, :string
    add_column :users, :last_name, :string
    add_column :users, :gender, :integer
    add_column :users, :mobile_number, :string
    add_column :users, :is_accept_edm, :boolean
  end
end
