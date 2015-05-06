class CreateInvitations < ActiveRecord::Migration
  def change
    create_table :invitations, option: "CHARSET=utf8 COLLATE=utf8_general_ci" do |t|
      t.string :key,           null: false
      t.string :share_point,   null: false
      t.integer :permission,   limit: 1,    default: 0 # 0:DENY, 1:R, 2:RW
      t.references :device_id, index: true, null: false
      t.integer :expire_count, default: 0

      t.timestamps
    end
  end
end
