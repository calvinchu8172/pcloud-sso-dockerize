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

end
