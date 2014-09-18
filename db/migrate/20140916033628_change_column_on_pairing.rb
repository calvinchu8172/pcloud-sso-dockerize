class ChangeColumnOnPairing < ActiveRecord::Migration
  def up
    remove_column :pairings, :enabled
    remove_index  :pairings, name: "index_pairings_on_user_id"

    add_column    :pairings, :ownership, :integer, null: false, limit: 1

    change_column :pairings, :user_id,   :integer, null: false
    change_column :pairings, :device_id, :integer, null: false

    add_index     :pairings, [:user_id, :device_id], unique: true
  end
  def down
    add_column    :pairings, :enabled, :boolean
    add_index     :pairings, :user_id

    remove_column :pairings, :ownership

    change_column :pairings, :user_id,   :integer
    change_column :pairings, :device_id, :integer

    remove_index  :pairings, name: "index_pairings_on_user_id_and_device_id"
  end
end
