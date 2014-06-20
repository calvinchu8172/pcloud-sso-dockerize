class PairingSession < ActiveRecord::Base

  enum status: {start: 0, waiting: 1, done: 2, offline: 3, failure: 4}

  belongs_to :user
  belongs_to :device

  def self.handling_status
    self.statuses.slice(:start, :waiting, :done)
  end

  def self.handling_by_user(user_id)
  	self.where("user_id = ? AND status not in (?) AND expire_at > NOW()", user_id, self.handling_status.map{|k,v| v}.join(','));
  end


end
