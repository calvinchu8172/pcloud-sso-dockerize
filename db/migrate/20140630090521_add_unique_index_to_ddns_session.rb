class AddUniqueIndexToDdnsSession < ActiveRecord::Migration
  def change
    add_index :ddns, :full_domain, unique: true
  end
end
