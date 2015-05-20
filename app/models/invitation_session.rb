class InvitationSession
	include Redis::Objects

	attr_accessor :id

	self.redis_prefix = 'invitation'

	hash_key :session

	def self.create invitation_id, cloud_id
		session = self.new
		session.id = "invitation:#{invitation_id}:#{cloud_id}:session"
	  	session
	end

	def self.find invitation_id, cloud_id
		redis = Redis.new
		session = redis.hgetall "invitation:#{invitation_id}:#{cloud_id}:session"
	  	session
	end
end
