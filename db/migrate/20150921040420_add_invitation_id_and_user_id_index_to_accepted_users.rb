class AddInvitationIdAndUserIdIndexToAcceptedUsers < ActiveRecord::Migration
  def change
    add_index :accepted_users, [:invitation_id, :user_id], unique: true, name: 'index_accepted_users_on_invitation_id_and_user_unique'
  end
end
