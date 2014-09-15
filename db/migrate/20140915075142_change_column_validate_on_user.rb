class ChangeColumnValidateOnUser < ActiveRecord::Migration
  def change
    change_column :users, :encrypted_password, "char(60)", default: "", null: false
    change_column :users, :language,           "char(5)"
    change_column :users, :country,            "char(2)"
    change_column :users, :edm_accept,         :boolean
  end
end
