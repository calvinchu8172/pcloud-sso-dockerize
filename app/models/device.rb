class Device < ActiveRecord::Base

  has_one :device_session

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
