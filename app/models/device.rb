class Device < ActiveRecord::Base

  belongs_to :product, foreign_key: 'model_name', primary_key: 'model_name'
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
