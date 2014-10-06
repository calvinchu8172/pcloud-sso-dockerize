class CreateIdentities < ActiveRecord::Migration
  def change
    create_table :identities, option: "CHARSET=utf8 COLLATE=utf8_general_ci" do |t|
      t.references :user, index: true
      t.string :provider
      t.string :uid

      t.timestamps
    end
  end
end
