class AddIndexOnIdentity < ActiveRecord::Migration
  def change
    change_column :identities, :user_id,  :integer,   null:   false
    change_column :identities, :provider, "char(15)", null:   false
    change_column :identities, :uid,      :string,    null:   false
    add_index     :identities, [:provider, :user_id], unique: true
  end
end
