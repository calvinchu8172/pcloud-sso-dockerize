class ChangeColumnOfUser < ActiveRecord::Migration
  def up
    change_column :users, :language, :string, limit: 30, default: "en", null: false
    change_column :users, :country, :string, limit: 100, null: true
  end
  def down
    change_column :users, :language, :string, limit: 30
    change_column :users, :country, :string, limit: 100, null: false
  end
end
