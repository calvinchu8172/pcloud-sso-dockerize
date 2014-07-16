class RemoveIsAcceptEdmFromUsers < ActiveRecord::Migration
  def change
    remove_column :users, :is_accept_edm, :boolean
  end
end
