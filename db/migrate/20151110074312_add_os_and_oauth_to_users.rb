class AddOsAndOauthToUsers < ActiveRecord::Migration
  def change
    add_column :users, :os, :string, :default => nil
    add_column :users, :oauth, :string, :default => nil
  end
end
