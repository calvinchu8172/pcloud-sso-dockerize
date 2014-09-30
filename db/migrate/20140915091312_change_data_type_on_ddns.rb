class ChangeDataTypeOnDdns < ActiveRecord::Migration
  def change
    change_column :ddns,    :ip_address,  "char(8)",  null: false
    change_column :ddns,    :device_id,   :integer,   null: false
  end
end
