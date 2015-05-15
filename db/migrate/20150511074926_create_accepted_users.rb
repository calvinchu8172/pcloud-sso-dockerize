class CreateAcceptedUsers < ActiveRecord::Migration
  def change
    create_table :accepted_users, option: "CHARSET=utf8 COLLATE=utf8_general_ci" do |t|
      t.references :invitation, index: true, null: false
      t.references :user, index: true, null: false
      t.integer :status, limit: 1

      t.timestamps
    end
  end
end
