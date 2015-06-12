class AddCertificate < ActiveRecord::Migration
  def change
  	create_table :certificates do |t|
  	  t.string :serial, null: false
      t.text :content, null: false
    end
  end
end
