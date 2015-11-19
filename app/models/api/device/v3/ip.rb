class Api::Device::V3::Ip
  include Redis::Objects
  attr_accessor :origin_id, #mac_address + serial_number
                :ip_address,
                :mac_address,
                :serial_number,
                :lan_ip

  self.redis_prefix= 'device:lite:ip'
  self.redis_id_field :ip_address

  list :activities, expiration: 30.seconds

  def initialize params = {}
    params.each { |key, value| send "#{key}=", value }
  end

  def self.create(ip, origin_id)
    instance = new(ip_address: ip, origin_id: origin_id)
    instance.activities << origin_id
  end

  def self.find_activities(ip)
    instance = self.new(ip_address: ip)
    instance.activities
  end
end