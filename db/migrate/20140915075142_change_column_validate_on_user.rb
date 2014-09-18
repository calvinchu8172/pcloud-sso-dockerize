class ChangeColumnValidateOnUser < ActiveRecord::Migration
  def up
    change_column :users, :encrypted_password, "char(60)", default: "", null: false
    change_column :users, :language,           "char(5)"
    change_column :users, :country,            "char(2)"
    change_column :users, :edm_accept,         :boolean
    change_column :users, :gender,             :boolean
    change_column :users, :mobile_number,      :string,    limit: 40
  end
  def down
    change_column :users, :encrypted_password, :string,    default: "", null: false
    change_column :users, :language,           :string,    limit: 120
    change_column :users, :country,            :string,    limit: 120
    change_column :users, :edm_accept,         :integer
    change_column :users, :gender,             :integer
    change_column :users, :mobile_number,      :string
  end
end
