class Pairing < ActiveRecord::Base

  scope :enabled, -> { where(enabled: true) }

  belongs_to :user
  belongs_to :device

  
  def disable
  	self.enabled = false
  	save
  end
end
