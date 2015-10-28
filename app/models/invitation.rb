class Invitation < ActiveRecord::Base
	include Guards::AttrEncryptor
  has_many :accepted_users, dependent: :destroy
	belongs_to :device

 	READ_ONLY = 1
 	READ_WRITE = 2

 	PERMISSIONS = {
 		READ_ONLY => "RO",
 		READ_WRITE => "RW"
 	}

	def permission_name
    PERMISSIONS[self.permission]
  end

  # decreasing the expire_count of invitation
  # creating accepted_user data
  def accepted_by user_id
  	self.expire_count -= 1
  	self.save

    accepted_user = AcceptedUser.create(invitation_id: self.id, user_id: user_id, status: 0)
    accepted_user.save
  end

  def self.handle_permission? permission
    PERMISSIONS.has_key?(permission.to_i)
  end
end
