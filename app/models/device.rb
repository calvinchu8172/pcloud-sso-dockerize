class Device < ActiveRecord::Base

  has_one :device_session

  before_save { mac_address.downcase! }
  VALID_MAC_ADDRESS_REGEX = /^([0-9a-f]{2}:){5}[0-9a-f]{2}$/i
  validates :mac_address, format: { with VALID_MAC_ADDRESS_REGEX }

  def self.checkin args

  	result = self.where( args.permit(:mac_address, :serial_number))
  		
  	if result.empty?
  		instance = self.create(args)
  	else
  		instance = result.first
  	end
  	return instance
  end
end
