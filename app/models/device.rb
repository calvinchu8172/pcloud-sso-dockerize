class Device < ActiveRecord::Base

  belongs_to :product
  has_one :device_session
  has_one :ddns

  before_save { mac_address.downcase! }
  # VALID_MAC_ADDRESS_REGEX = /^([0-9a-f]{2}:){5}[0-9a-f]{2}$/i
  # validates :mac_address, format: { with VALID_MAC_ADDRESS_REGEX }

  def self.checkin args

  	result = self.where( args.permit(:mac_address, :serial_number))
    product = Product.where(args.permit(:model_name))
  	if result.empty?
  		instance = self.create(args.permit(:mac_address, :serial_number, :firmware_version), product_id: product.id)
      logger.info('create new device')
  	else
  		instance = result.first
      unless args[:firmware_version] == instance.firmware_version
        logger.info('update device from fireware version' + args[:firmware_version] + ' from ' + instance.firmware_version)
        instance.update_attribute(:firmware_version, args[:firmware_version])
      end
  	end
  	return instance
  end

  def reset

  end

end
