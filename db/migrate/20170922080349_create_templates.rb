class CreateTemplates < ActiveRecord::Migration
  def change
    create_table :templates do |t|
      t.string :identity, index: true, null: false


      t.timestamps null: false
    end
  end
end
