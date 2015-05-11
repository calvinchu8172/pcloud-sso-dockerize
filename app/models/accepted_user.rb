class AcceptedUser < ActiveRecord::Base
  belongs_to :invitation
  belongs_to :user


	def accepted_time
		self.updated_at.strftime("%Y-%m-%d %H:%M:%S")	
	end

	def user_email
		self.user.email
	end

	def accepted_successfully?
		self.status == 1
	end

	def inbox? last_updated_at
		logger.debug("last_updated_at: #{last_updated_at.to_i}")
		self.accepted_successfully? && self.updated_at.to_i > last_updated_at.to_i
	end

end
