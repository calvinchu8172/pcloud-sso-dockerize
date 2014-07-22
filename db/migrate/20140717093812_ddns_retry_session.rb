class DdnsRetrySession < ActiveRecord::Migration
  def change
  	create_table :ddns_retry_sessions do |t|
      t.references :device, index: true, :null => false
      t.string :full_domain, :default => 0, :null => false
      t.datetime :created_at, :null => false
      t.datetime :updated_at, :null => false
      t.timestamps
    end
  end
end
