class CreateAcceptedUsers < ActiveRecord::Migration
  def change
    create_table :accepted_users do |t|
      t.references :invitation, index: true, null: false
      t.references :user, 		index: true, null: false
      t.integer :status, 		limit: 1

      t.timestamps
    end
  end
end
