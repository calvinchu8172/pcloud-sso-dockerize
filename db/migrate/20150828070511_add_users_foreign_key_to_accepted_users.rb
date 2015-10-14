class AddUsersForeignKeyToAcceptedUsers < ActiveRecord::Migration
  def change
    add_foreign_key :accepted_users, :users, column: :user_id, name: 'accepted_users_user_id_fk'
    add_foreign_key :accepted_users, :invitations, column: :invitation_id, name: 'accepted_users_invitation_id_fk'
  end
end
