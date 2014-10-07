class AddDomainRefToDdns < ActiveRecord::Migration
  def change
    add_reference :ddns, :domain, index: false

    remove_index :ddns, column: :full_domain
    remove_column :ddns, :full_domain

    add_column :ddns, :hostname, :string, limit: 63, null: false

    add_index :ddns, [:device_id], name: "index_domains_on_domain_name_unique", unique: true
    add_index :ddns, [:hostname, :domain_id], unique: true
  end
end
