class InvitationSession < ActiveRecord::Base
	include Redis::Objects


	self.redis_prefix = 'invitation'

	hash_key :session


	def create

	end

end
