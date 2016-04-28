class CreateVendorSourceIps < ActiveRecord::Migration
  def change
    create_table :vendor_source_ips do |t|
      t.integer :vendor_id,                 null: false
      t.string  :ip_address,    limit: 15,  null: false

      t.timestamps null: false
    end
  end
end
