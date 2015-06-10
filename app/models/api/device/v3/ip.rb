class Api::Device::V3::Ip
  include Redis::Objects
  attr_accessor :origin_id, #mac_address + serial_number
                :ip_address,
                :mac_address,
                :serial_number

  self.redis_prefix= 'device:lite:ip'
  self.redis_id_field :ip_address

  list :activities, expiration: 30.seconds

  def initialize params = {}
    params.each { |key, value| send "#{key}=", value }
  end

  def self.create(ip, origin_id)

  end
end