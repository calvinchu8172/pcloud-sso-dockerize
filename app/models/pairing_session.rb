class PairingSession < ActiveRecord::Base

  enum status: {start: 0, waiting: 1, done: 2, offline: 3, failure: 4}

  belongs_to :user
  belongs_to :device

  def self.unavailable_status
    Hash[self.statuses.sort_by { |k,v| -v }[0..1]]
  end
end
