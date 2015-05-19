class InvitationSession
	include Redis::Objects

	attr_accessor :id

	self.redis_prefix = 'invitation'

	hash_key :session

	# def self.create invitation_id, cloud_id
	# 	session = self.new
	# 	session.id = "#{invitation_id}:#{cloud_id}"
	#   	session
	# end

end
