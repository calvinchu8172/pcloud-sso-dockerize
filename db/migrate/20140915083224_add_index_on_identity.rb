class AddIndexOnIdentity < ActiveRecord::Migration
  def change
    change_column :identities, :user_id,  :integer,   null:   false
    change_column :identities, :provider, "char(15)", null:   false
    change_column :identities, :uid,      :string,    null:   false

    add_index     :identities, [:provider, :uid], unique: true
    add_index     :identities, [:user_id, :provider], unique: true

    remove_index  :identities, column: :user_id
  end
end
