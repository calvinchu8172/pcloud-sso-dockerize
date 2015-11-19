class Pairing < ActiveRecord::Base
  scope :owner, -> { where(ownership: 0) }

  include Guards::AttrEncryptor

  belongs_to :user
  belongs_to :device
  has_many :invitations, :through => :device

  START_PERIOD = 10.seconds
  WAITING_PERIOD = 10.minutes

  before_destroy :destroy_invitations

  def destroy_invitations
    self.invitations.each { |invitation| invitation.destroy }
  end

end
