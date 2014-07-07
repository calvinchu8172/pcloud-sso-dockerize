class Pairing < ActiveRecord::Base

  scope :enabled, -> { where(enabled: true) }

  belongs_to :user
  belongs_to :device

  def ping 

  end
end
