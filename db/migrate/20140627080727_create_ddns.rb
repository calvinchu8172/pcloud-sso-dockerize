class CreateDdns < ActiveRecord::Migration
  def change
    create_table :ddns, option: "CHARSET=utf8 COLLATE=utf8_general_ci" do |t|
      t.references :device, index: true
      t.string :ip_address, limit: 100
      t.string :full_domain, limit: 100

      t.timestamps
    end
  end
end
