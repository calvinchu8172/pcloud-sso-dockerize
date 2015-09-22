class RenameIndexesOfDdns < ActiveRecord::Migration
  def change
    rename_index :ddns, 'index_domains_on_domain_name_unique', 'index_ddns_on_device_id_unique'
    rename_index :ddns, 'index_ddns_on_hostname_and_domain_id', 'index_ddns_on_hostname_and_domain_id_unique'
    remove_index :ddns, :name => 'index_ddns_on_device_id'
  end
end
