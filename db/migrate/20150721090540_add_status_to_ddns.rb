class AddStatusToDdns < ActiveRecord::Migration
  def change
    add_column :ddns, :status, :integer, :default => nil
  end
end
