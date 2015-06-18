class InvitationSession
	include Redis::Objects

	attr_accessor :id

	self.redis_prefix = 'invitation'

	hash_key :session

end
