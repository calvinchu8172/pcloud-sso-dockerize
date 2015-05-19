class Invitation < ActiveRecord::Base
	has_many :accepted_users
	belongs_to :device

 	READ_ONLY = 1
 	READ_WRITE = 2

 	PERMISSIONS = {
 		READ_ONLY => "R", 
 		READ_WRITE => "RW"
 	}

	def permission_name
    PERMISSIONS[self.permission]
  end

  def session user_email
  	InvitationSession.find(self.device.id, user_email)
  end

  # decreasing the expire_count of invitation
  # creating accepted_user data
  def accepted_by user_id
  	self.expire_count -= 1 
  	self.save
    
    accepted_user = AcceptedUser.create(invitation_id: self.id, user_id: user_id, status: 0)
    accepted_user.save
  end
end
