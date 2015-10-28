class Api::Device::V3::Lite < Api::Device
  include Redis::Objects

  validates_with SslValidator, signature_key: [:certificate_serial, :mac_address, :serial_number, :model_class_name, :firmware_version]

  attr_accessor :origin_id, #mac_address + serial_number
                :mac_address,
                :serial_number,
                :model_class_name,
                :firmware_version,
                :certificate_serial,
                :signature,
                :alog,
                :ip_address,
                :lan_ip

  self.redis_prefix= 'device:lite'
  self.redis_id_field :origin_id

  hash_key :info, expiration: 30.seconds

  def map_info!
    self.attributes = self.info.all
  end

  def self.trigger(params = {})
    instance = self.new(params)
    return instance unless instance.valid?

    instance.origin_id = params[:mac_address] + params[:serial_number]
    instance.info.bulk_set(params.except(:certificate_serial, :signature, :algo))

    ip = Api::Device::V3::Ip.create(instance.ip_address, instance.origin_id)
    instance
  end

  def self.find(origin_id)
    instance = self.new(origin_id: origin_id)
    instance.map_info!
    instance
  end

  def self.find_by_ip(ip_address)
    result = []
    Api::Device::V3::Ip.find_activities(ip_address).each do |device_origin_id|
      instance = find(device_origin_id)
      result << instance unless instance.mac_address.blank? or instance.serial_number.blank?
    end
    result
  end
end