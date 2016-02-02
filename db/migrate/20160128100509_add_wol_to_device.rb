class AddWolToDevice < ActiveRecord::Migration
  def up
    add_column :devices, :online_status, :integer, limit: 1, null: false, default: 0
    add_column :devices, :wol_status, :integer, limit: 1, null: false, default: 0
  end

  def down
    remove_column :devices, :online_status
    remove_column :devices, :wol_status
  end
end
