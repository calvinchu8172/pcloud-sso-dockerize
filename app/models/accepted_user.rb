class AcceptedUser < ActiveRecord::Base
	include Redis::Objects
 	belongs_to :invitation
 	belongs_to :user

	hash_key :session
 	self.redis_prefix = 'invitation'
 	WAITING_PERIOD = 30.seconds


	def accepted_time
		self.updated_at.strftime("%Y-%m-%d %H:%M:%S")
	end

	def inbox? last_updated_at
		self.status == 1 && self.updated_at.to_i > last_updated_at.to_i
	end

	def self.handling_status
	  ['start']
	end

	def session_expire_in
	  waiting_second = AcceptedUser::WAITING_PERIOD.to_i
	  return 0 if !self.class.handling_status.include?(session.get('status'))

	  time_difference = self.session.get('expire_at').to_i - Time.now().to_i
	  return time_difference
	end

	def finish_accept
		self.update(:status => 1)
	end

end
