class AddVendorIdToCertificates < ActiveRecord::Migration
  def change
    add_column :certificates, :vendor_id, :integer
  end
end
