class CreateDdnsSessions < ActiveRecord::Migration
  def change
    create_table :ddns_sessions do |t|
      t.references :device, index: true
      t.string :full_domain
      t.integer :status

      t.timestamps
    end
  end
end
