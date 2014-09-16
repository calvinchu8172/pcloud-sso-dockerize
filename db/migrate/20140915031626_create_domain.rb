class CreateDomain < ActiveRecord::Migration
  def up
    create_table :domains do |t|
      t.string :domain_name, limit: 192, null: false
      t.timestamps
    end
    add_index :domains, [:id, :domain_name], unique: true
  end
  def down
    drop_table :domains
  end
end
