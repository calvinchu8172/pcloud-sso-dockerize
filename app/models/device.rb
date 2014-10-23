class Device < ActiveRecord::Base
  include Redis::Objects
  include Guards::AttrEncryptor
  
  belongs_to :product
  has_one :device_session
  has_one :ddns

  has_many :pairing

  hash_key :session
  hash_key :pairing_session

  # attr_encrypted :id, :key => Rails.application.secrets.secret_key_base

  IP_ADDRESSES_KEY = 'device:ip_addresses:'
  WAITING_TIME = 10.minutes

  before_save { mac_address.downcase! }

  def self.handling_status
    ['start', 'waiting']
  end

  def self.checkin args

    result = self.where( args.permit(:mac_address, :serial_number))
    if result.empty?

      product = Product.where(args.permit(:model_name))
      unless product.first.nil?
        instance = self.create(args.permit(:mac_address, :serial_number, :firmware_version), product_id: product.first.id)
        logger.info('create new device id:' + instance.id.to_s)
      end
    else
      instance = result.first
      unless args[:firmware_version] == instance.firmware_version
        logger.info('update device from fireware version' + args[:firmware_version] + ' from ' + instance.firmware_version)
        instance.update_attribute(:firmware_version, args[:firmware_version])
      end
    end
    return instance
  end

  def self.ip_addresses_key_prefix
    IP_ADDRESSES_KEY
  end
  
  def paired?
    !self.pairing.owner.empty?
  end  
  
  def update_ip_list new_ip

    unless self.session.get(:ip).nil?
      old_ip_list = Redis::HashKey.new( IP_ADDRESSES_KEY + self.session.get(:ip))
      old_ip_list.delete(self.id)
    end

    new_ip_list = Redis::HashKey.new( IP_ADDRESSES_KEY + new_ip)
    new_ip_list.store(self.id, 1)
    
  end

  def pairing_session_expire_in
    pairing_session.get('expire_at').to_f - Time.now().to_f if self.class.handling_status.include?(pairing_session.get('status'))
  end

  def presence?

    if @presence.nil?
      session = self.session.all
      @presence = XmppPresence.new("s3:#{session['xmpp_account']}:#{Settings.xmpp.server}:#{Settings.xmpp.device_resource_id}".downcase)
    end
    @presence.exists?
  end

end
