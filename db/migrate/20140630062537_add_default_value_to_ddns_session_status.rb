class AddDefaultValueToDdnsSessionStatus < ActiveRecord::Migration
  def up
    change_column :ddns_sessions, :status, :integer, default: 0, null: false
    change_column :ddns_sessions, :full_domain, :string, limit: 100, null: false
  end
  def down
    change_column :ddns_sessions, :status, :integer
    change_column :ddns_sessions, :full_domain, :string
  end
end
