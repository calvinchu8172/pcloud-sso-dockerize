class Device < ActiveRecord::Base
  include Redis::Objects

  belongs_to :product, foreign_key: 'model_name', primary_key: 'model_name'
  has_one :device_session
  has_one :ddns

  hash_key :session
  hash_key :pairing_session, :expireat => Time.now + 2.minutes

  before_save { mac_address.downcase! }
  # VALID_MAC_ADDRESS_REGEX = /^([0-9a-f]{2}:){5}[0-9a-f]{2}$/i
  # validates :mac_address, format: { with VALID_MAC_ADDRESS_REGEX }

  def self.handling_status
    [:start, :waiting]
  end

  def self.checkin args

  	result = self.where( args.permit(:mac_address, :serial_number))
  		
  	if result.empty?
  		instance = self.create(args)
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

  def update_ip_list new_ip

    unless self.session.get(:ip).nil?
      old_ip_list = Redis::HashKey.new('device:ip_addresses:' + self.session.get(:ip))
      old_ip_list.delete(self.id)
    end

    unless Pairing.exists?(:device_id => self.id)
      new_ip_list = Redis::HashKey.new("device:ip_addresses:" + new_ip)
      new_ip_list.store(self.id, 1)
    end
  end

end
