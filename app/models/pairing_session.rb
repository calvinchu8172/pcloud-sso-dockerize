class PairingSession < ActiveRecord::Base

  enum status: {start: 0, waiting: 1, done: 2, offline: 3, failure: 4}

  belongs_to :user
  belongs_to :device

  def self.handling_status
    self.statuses.slice(:start, :waiting, :done)
  end

  def self.handling_by_user(user_id)
  	self.where("user_id = ? AND status in (?) AND expire_at > NOW()", user_id, self.handling_status.map{|k,v| v}.join(','));
  end

  def self.handling()
  	self.where("status in (?) AND expire_at > NOW()", self.handling_status.map{|k,v| v});
  end

  def expire_in
    expire_time = self.expire_at.to_f - Time.now.to_f - 90
    expire_time = 600 if expire_time > 600
    return expire_time.to_i
  end
end
