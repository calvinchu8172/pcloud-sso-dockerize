class AddDomainRefToDdns < ActiveRecord::Migration
  def change
    add_reference :ddns, :domain, index: true

    remove_index :ddns, column: :full_domain
    remove_column :ddns, :full_domain

    add_column :ddns, :hostname, :string, limit: 63

    add_index :ddns, [:device_id], name: 'index_ddns_on_device_id_unique', unique: true
    add_index :ddns, [:hostname, :domain_id], unique: true
  end
end
